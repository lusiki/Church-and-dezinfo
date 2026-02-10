# ==============================================================================
# 01_data_preparation.R
# Disinformation Narratives in Croatian Catholic Media
# Data Preparation Pipeline (OPTIMIZED)
# ==============================================================================
#
# Optimizations vs. original:
#   1. Filters to SOURCE_TYPE == "web" immediately (drops ~80% of rows)
#   2. No topic dictionaries (removed entirely)
#   3. No sentiment / emotional intensity computation
#   4. Single regex pass per frame (count), boolean derived from count > 0
#   5. Disinfo alignment index based on frames only
#
# OUTPUT:
#   - catholic_media_full_corpus.rds
#   - catholic_media_contested_corpus.rds  (now: articles with any frame)
#   - catholic_media_catholic_corpus.rds
#   - catholic_media_catholic_contested.rds
#   - catholic_media_summary_stats.xlsx
#   - data_preparation_log.txt
#
# ==============================================================================


# ==============================================================================
# SECTION 0: CONFIGURATION
# ==============================================================================

# NOTE: DATA_FILE_PATH must point to your local copy of merged_comprehensive.rds
# This file is too large for the repository and must be obtained separately.
# See README.md for instructions.
DATA_FILE_PATH <- Sys.getenv("DIGIKAT_DATA_PATH",
                             unset = file.path(here::here(), "data", "merged_comprehensive.rds"))
OUTPUT_DIR     <- file.path(here::here(), "data")

dir.create(OUTPUT_DIR, showWarnings = FALSE, recursive = TRUE)

log_file <- file.path(OUTPUT_DIR, "data_preparation_log.txt")
log_msg <- function(msg) {
  timestamp <- format(Sys.time(), "%Y-%m-%d %H:%M:%S")
  line <- paste0("[", timestamp, "] ", msg)
  cat(line, "\n")
  cat(line, "\n", file = log_file, append = TRUE)
}

cat("", file = log_file)
log_msg("Pipeline started (optimized: web only, frames + actors)")
log_msg(paste("Input file:", DATA_FILE_PATH))
log_msg(paste("Output directory:", OUTPUT_DIR))


# ==============================================================================
# SECTION 1: PACKAGES
# ==============================================================================

required_packages <- c(
  "dplyr", "tidyr", "stringr", "stringi", "lubridate",
  "readxl", "openxlsx", "forcats", "tibble"
)

for (pkg in required_packages) {
  if (!require(pkg, character.only = TRUE, quietly = TRUE)) {
    install.packages(pkg, quiet = TRUE)
    library(pkg, character.only = TRUE)
  }
}

options(dplyr.summarise.inform = FALSE, scipen = 999)
log_msg("Packages loaded")


# ==============================================================================
# SECTION 2: DATA LOADING AND VALIDATION
# ==============================================================================

ext <- tolower(tools::file_ext(DATA_FILE_PATH))
log_msg(paste("Detected file format:", ext))

df <- switch(ext,
  "xlsx" = read_excel(DATA_FILE_PATH, guess_max = 50000),
  "xls"  = read_excel(DATA_FILE_PATH, guess_max = 50000),
  "csv"  = read.csv(DATA_FILE_PATH, stringsAsFactors = FALSE, fileEncoding = "UTF-8"),
  "rds"  = readRDS(DATA_FILE_PATH),
  stop("Unsupported file format: ", ext)
)

log_msg(paste("Raw data loaded:", format(nrow(df), big.mark = ","), "rows,", ncol(df), "columns"))

required_cols <- c("DATE", "TITLE", "FULL_TEXT", "FROM", "SOURCE_TYPE")
missing_cols <- setdiff(required_cols, names(df))
if (length(missing_cols) > 0) {
  stop("Missing required columns: ", paste(missing_cols, collapse = ", "))
}
log_msg("Required columns validated")


# ==============================================================================
# SECTION 3: EARLY FILTER + DATA CLEANING
# ==============================================================================

n_raw <- nrow(df)

# --- KEY OPTIMIZATION: filter to web only ---
df <- df |> filter(SOURCE_TYPE == "web")
log_msg(paste("Filtered to web only:", format(nrow(df), big.mark = ","),
              "rows (dropped", format(n_raw - nrow(df), big.mark = ","), "non-web)"))

# Remove records with no text
n_before <- nrow(df)
df <- df |> filter(!is.na(FULL_TEXT) & nchar(trimws(FULL_TEXT)) > 0)
log_msg(paste("Removed", n_before - nrow(df), "records with empty FULL_TEXT"))

# Parse dates
df$DATE <- as.Date(df$DATE)
df <- df |> filter(!is.na(DATE))

# Temporal variables
df <- df |>
  mutate(
    year         = year(DATE),
    month        = month(DATE),
    year_month   = floor_date(DATE, "month"),
    week         = isoweek(DATE),
    quarter      = quarter(DATE),
    year_quarter = paste0(year, " Q", quarter),
    day_of_week  = wday(DATE, label = TRUE, abbr = FALSE, locale = "en_US.UTF-8")
  )

# Deduplicate
if ("URL" %in% names(df)) {
  n_before <- nrow(df)
  df <- df |> distinct(URL, .keep_all = TRUE)
  log_msg(paste("Removed", n_before - nrow(df), "duplicates by URL"))
} else {
  n_before <- nrow(df)
  df <- df |> distinct(TITLE, DATE, FROM, .keep_all = TRUE)
  log_msg(paste("Removed", n_before - nrow(df), "duplicates by TITLE+DATE+FROM"))
}

# Fix Croatian decimal separators
comma_cols <- intersect(c("VIRALITY", "ENGAGEMENT_RATE"), names(df))
for (col in comma_cols) {
  if (is.character(df[[col]])) {
    df[[col]] <- as.numeric(gsub(",", ".", df[[col]]))
  }
}

# Ensure engagement columns are numeric
engagement_cols <- intersect(
  c("INTERACTIONS", "LIKE_COUNT", "COMMENT_COUNT", "SHARE_COUNT",
    "LOVE_COUNT", "WOW_COUNT", "HAHA_COUNT", "SAD_COUNT", "ANGRY_COUNT",
    "TOTAL_REACTIONS_COUNT", "REACH", "VIEW_COUNT"),
  names(df)
)
for (col in engagement_cols) {
  df[[col]] <- as.numeric(df[[col]])
  df[[col]][is.na(df[[col]])] <- 0
}

# Lowercase text (single allocation, used by all downstream regex)
df$.text_lower <- stri_trans_tolower(
  paste(coalesce(df$TITLE, ""), coalesce(df$FULL_TEXT, ""), sep = " ")
)

df$word_count <- stri_count_regex(df$FULL_TEXT, "\\S+")

log_msg(paste("Cleaned web corpus:", format(nrow(df), big.mark = ","), "rows"))


# ==============================================================================
# SECTION 4: MEDIA OUTLET CLASSIFICATION
# ==============================================================================

catholic_official <- c(
  "ika\\.hkm", "glas.koncila", "glas-koncila", "hkm\\.hr", "laudato",
  "ktabkbih", "ika\\.hr"
)
catholic_radio <- c(
  "radiomarija", "radio.marija", "hkr\\.hr", "radio\\.hkm"
)
catholic_portals <- c(
  "bitno\\.net", "katolicki", "vjera\\.hr", "svetiste", "zupa",
  "biskupija", "nadbiskupija", "franjevci", "dominikanci"
)
catholic_aligned <- c(
  "narod\\.hr", "dnevno\\.hr", "7dnevno", "direktno\\.hr",
  "maxportal", "projekt-velebit", "hrvatskadobrobit"
)

conservative_outlets <- c("vecernji", "hrt\\.hr", "nacional", "glas\\.hr")
liberal_outlets      <- c("index\\.hr", "telegram\\.hr", "n1\\.hr", "n1info", "net\\.hr", "tportal")
tabloid_outlets      <- c("24sata", "jutarnji", "rtl\\.hr", "nova\\.hr", "dnevnik\\.hr", "story\\.hr")
regional_outlets     <- c("slobodna.*dalmacija", "slobodnadalmacija", "novi.*list", "novilist",
                          "glas.slavonije", "glas-slavonije", "dubrovacki", "zadarskilist", "034portal")
business_outlets     <- c("poslovni", "lider\\.hr", "bug\\.hr", "netokracija", "forbes.*hr", "poslovnipuls")

match_any <- function(from_lower, patterns) {
  stri_detect_regex(from_lower, paste(patterns, collapse = "|"))
}

from_lower <- stri_trans_tolower(df$FROM)

df$catholic_subcategory <- case_when(
  match_any(from_lower, catholic_official) ~ "Official Church",
  match_any(from_lower, catholic_radio)    ~ "Catholic Radio",
  match_any(from_lower, catholic_portals)  ~ "Catholic Portals",
  match_any(from_lower, catholic_aligned)  ~ "Catholic Aligned",
  TRUE ~ NA_character_
)

df$media_type <- case_when(
  !is.na(df$catholic_subcategory)             ~ "Catholic",
  match_any(from_lower, conservative_outlets) ~ "Conservative",
  match_any(from_lower, liberal_outlets)      ~ "Liberal",
  match_any(from_lower, tabloid_outlets)      ~ "Tabloid",
  match_any(from_lower, regional_outlets)     ~ "Regional",
  match_any(from_lower, business_outlets)     ~ "Business",
  TRUE ~ "Other"
)

media_dist <- df |> count(media_type, sort = TRUE)
log_msg("Media classification complete:")
for (i in seq_len(nrow(media_dist))) {
  log_msg(paste("  ", media_dist$media_type[i], ":", format(media_dist$n[i], big.mark = ",")))
}

catholic_sub_dist <- df |> filter(media_type == "Catholic") |> count(catholic_subcategory, sort = TRUE)
if (nrow(catholic_sub_dist) > 0) {
  log_msg("Catholic subcategories:")
  for (i in seq_len(nrow(catholic_sub_dist))) {
    log_msg(paste("  ", catholic_sub_dist$catholic_subcategory[i], ":",
                  format(catholic_sub_dist$n[i], big.mark = ",")))
  }
}


# ==============================================================================
# SECTION 5: NARRATIVE FRAME DETECTION
# ==============================================================================
#
# Single pass per frame: stri_count_regex returns counts.
# Boolean flag derived as count > 0. Dominant frame from max count.
#

frame_dictionaries <- list(
  MORAL_DECAY = c(
    "moralni pad", "moralni raspad", "moralna kriza",
    "dekadencija", "dekadentan",
    "grijeh", "griješan", "grješan",
    "sekularizacija", "bezbožn",
    "kultura smrti", "civilizacija smrti",
    "hedonizam", "relativizam", "nihilizam",
    "propadanje", "propast vrijednosti",
    "moralni relativizam", "bezakonje"
  ),
  FOREIGN_THREAT = c(
    "nametanje", "nameće nam",
    "briselski diktat", "diktat iz brisela",
    "soros", "george soros",
    "globalizam", "globalist",
    "novi svjetski poredak", "nwo",
    "strano uplitanje", "strana agenda",
    "ideološki import", "uvoz ideologije",
    "međunarodne elite", "svjetske elite"
  ),
  INSTITUTIONAL_DISTRUST = c(
    "laž", "lažu nas", "lažu",
    "manipulacija", "manipuliraju",
    "cenzura", "cenzuriraju",
    "propaganda", "propagandni",
    "duboka država", "deep state",
    "korupcija", "korumpirani",
    "sustav je pokvaren", "pokvareni sustav",
    "ne vjerujem", "nevjerodostojan"
  ),
  TRADITIONAL_VALUES = c(
    "tradicija", "tradicionalne vrijednosti",
    "obitelj", "obiteljs", "obiteljske vrijednosti",
    "brak", "brak između muškarca i žene",
    "vjera", "vjernick", "kršćanin",
    "domovina", "domoljublje", "domoljub",
    "crkva", "crkveni", "župn",
    "nasljeđe", "baština",
    "prirodni zakon", "božji zakon"
  ),
  SOVEREIGNTY = c(
    "suverenitet", "suverenost",
    "neovisnost", "nezavisnost",
    "referendum", "volja naroda",
    "nacionalni interes", "hrvatski interes",
    "samoodređenje", "samobitnost",
    "ustavni identitet", "identitetski",
    "predaja suvereniteta"
  ),
  CONSPIRACY = c(
    "zavjera", "konspiracija",
    "skrivena agenda", "skriveni plan",
    "kontrola populacije", "depopulacija",
    "big pharma", "farmaceutska mafija",
    "great reset", "veliki reset",
    "nova normalnost",
    "agenda 2030", "agenda2030",
    "planska demolucija", "planski",
    "iza kulisa", "marioneta",
    "orwellovski", "totalitarizam", "tiranja",
    "čipiranje", "5g", "bill gates"
  ),
  FAITH_DEFENCE = c(
    "kršćanofobija", "kristofobija",
    "progon kršćana", "progon vjernika",
    "napad na crkvu", "napadi na crkvu",
    "napad na vjeru", "napadi na vjernike",
    "evangelizacija", "nova evangelizacija",
    "vjerske slobode", "sloboda vjeroispovijesti",
    "obrana vjere", "obrana kršćanstva",
    "zaštita kršćanskih",
    "diskriminacija vjernika", "marginalizacija vjere"
  ),
  MEDIA_CRITIQUE = c(
    "mainstream mediji", "medijski mainstr",
    "fake news", "lažne vijesti",
    "pristranost", "pristrani mediji",
    "alternativni mediji", "nezavisni mediji",
    "medijska propaganda", "medijska manipulacija",
    "novinarska etika", "neetički",
    "prešućuju", "prešućivanje",
    "medijski mrak", "medijska blokada",
    "jednoumlje", "narativ"
  )
)

# Pre-compile patterns once
frame_patterns <- vapply(frame_dictionaries, function(terms) {
  paste0("(?i)(", paste(terms, collapse = "|"), ")")
}, character(1))

# Single count pass per frame
log_msg("Running frame detection (8 count passes)...")

frame_count_cols <- paste0("fcount_", names(frame_dictionaries))
frame_bool_cols  <- paste0("frame_",  names(frame_dictionaries))

for (i in seq_along(frame_dictionaries)) {
  fname <- names(frame_dictionaries)[i]
  counts <- stri_count_regex(df$.text_lower, frame_patterns[i])
  df[[paste0("fcount_", fname)]] <- counts
  df[[paste0("frame_",  fname)]] <- counts > 0L
  log_msg(paste("  ", fname, ":", format(sum(counts > 0L), big.mark = ",")))
}

# Derived frame variables
df$n_frames <- rowSums(df[, frame_bool_cols], na.rm = TRUE)
df$has_any_frame <- df$n_frames > 0L

fcount_mat <- as.matrix(df[, frame_count_cols])
df$dominant_frame <- ifelse(
  rowSums(fcount_mat, na.rm = TRUE) == 0,
  "NONE",
  names(frame_dictionaries)[max.col(fcount_mat, ties.method = "first")]
)

log_msg("Frame detection complete")


# ==============================================================================
# SECTION 6: ACTOR DETECTION
# ==============================================================================

actor_dictionaries <- list(
  CHURCH = c(
    "crkva", "crkveni", "biskupi", "biskup",
    "papa", "papa franjo", "sveti otac",
    "vatikan", "sveta stolica",
    "bozanić", "bozanic", "uzinić", "uzinovic",
    "kardinal", "nadbiskup", "župnik",
    "hbk", "biskupska konferencija"
  ),
  GOVERNMENT = c(
    "vlada", "premijer", "predsjednik vlade",
    "plenković", "plenkovic", "milanović", "milanovic",
    "sabor", "saborski zastupnik",
    "ministar", "ministarstvo",
    "hdz", "sdp", "most", "mozemo", "možemo",
    "domovinski pokret"
  ),
  EU_ACTORS = c(
    "europska komisija", "europski parlament",
    "brisel", "bruxelles",
    "von der leyen", "vijeće europe",
    "europski sud", "echr",
    "eu institucije"
  ),
  NGO_CIVIL = c(
    "udruga", "udruge", "nevladina organizacija",
    "civilno društvo", "civilni sektor",
    "aktivist", "aktivizam",
    "gong", "kuća ljudskih prava",
    "amnesty", "transparency"
  ),
  SCIENTISTS = c(
    "znanstvenik", "znanstvenica",
    "stručnjak", "stručnjakinja", "ekspert",
    "epidemiolog", "imunolog", "virolog",
    "who", "hzjz",
    "istraživač", "akademik", "profesor",
    "institut", "fakultet"
  ),
  MEDIA_ACTORS = c(
    "novinar", "novinarka", "novinarstvo",
    "mediji", "urednik", "uredništvo",
    "faktograf", "fact-check",
    "reportaža", "redakcija"
  ),
  FAMILY_ORGS = c(
    "u ime obitelji", "vigilare",
    "hod za život", "hod za zivot",
    "centar za obnovu kulture",
    "glas roditelja", "roditeljski",
    "pravo na život", "pro life"
  )
)

actor_patterns <- vapply(actor_dictionaries, function(terms) {
  paste0("(?i)(", paste(terms, collapse = "|"), ")")
}, character(1))

actor_cols <- paste0("actor_", names(actor_dictionaries))

log_msg("Running actor detection (7 detect passes)...")
for (i in seq_along(actor_dictionaries)) {
  aname <- names(actor_dictionaries)[i]
  df[[paste0("actor_", aname)]] <- stri_detect_regex(df$.text_lower, actor_patterns[i])
}
log_msg("Actor detection complete")


# ==============================================================================
# SECTION 7: DERIVED INDICES
# ==============================================================================

# Disinfo alignment (frame-only, no sentiment dependency)
df <- df |>
  mutate(
    disinfo_alignment = (
      frame_CONSPIRACY * 2 +
      frame_FOREIGN_THREAT * 1.5 +
      frame_INSTITUTIONAL_DISTRUST * 1.5 +
      frame_MEDIA_CRITIQUE * 1
    ),
    disinfo_alignment_norm = round(
      (disinfo_alignment - min(disinfo_alignment, na.rm = TRUE)) /
      max(max(disinfo_alignment, na.rm = TRUE) - min(disinfo_alignment, na.rm = TRUE), 1) * 100,
      1
    )
  )

# Narrative phase
df$narrative_phase <- case_when(
  df$DATE < as.Date("2021-07-01")                                      ~ "COVID Peak (early 2021)",
  df$DATE >= as.Date("2021-07-01") & df$DATE < as.Date("2022-02-24")   ~ "Post-Vaccine Debate",
  df$DATE >= as.Date("2022-02-24") & df$DATE < as.Date("2022-10-01")   ~ "Ukraine and Energy Crisis",
  df$DATE >= as.Date("2022-10-01") & df$DATE < as.Date("2023-01-15")   ~ "Euro Adoption",
  df$DATE >= as.Date("2023-01-15") & df$DATE < as.Date("2024-01-01")   ~ "Culture Wars Period",
  df$DATE >= as.Date("2024-01-01")                                      ~ "Election Run-up 2024",
  TRUE ~ "Other"
)

df$narrative_phase <- factor(df$narrative_phase, levels = c(
  "COVID Peak (early 2021)", "Post-Vaccine Debate",
  "Ukraine and Energy Crisis", "Euro Adoption",
  "Culture Wars Period", "Election Run-up 2024"
))

log_msg("Derived indices computed")
log_msg(paste("  Mean disinfo_alignment:", round(mean(df$disinfo_alignment, na.rm = TRUE), 3)))
log_msg(paste("  Mean disinfo_alignment_norm:", round(mean(df$disinfo_alignment_norm, na.rm = TRUE), 1)))


# ==============================================================================
# SECTION 8: SUBCORPORA
# ==============================================================================

full_corpus <- df
framed_corpus <- df |> filter(has_any_frame == TRUE)
catholic_corpus <- df |> filter(media_type == "Catholic")
catholic_framed <- df |> filter(media_type == "Catholic" & has_any_frame == TRUE)

log_msg("Subcorpora created:")
log_msg(paste("  Full corpus (web):", format(nrow(full_corpus), big.mark = ",")))
log_msg(paste("  Framed corpus:", format(nrow(framed_corpus), big.mark = ",")))
log_msg(paste("  Catholic corpus:", format(nrow(catholic_corpus), big.mark = ",")))
log_msg(paste("  Catholic framed:", format(nrow(catholic_framed), big.mark = ",")))


# ==============================================================================
# SECTION 9: EXPORT
# ==============================================================================

# Drop .text_lower and fcount_ columns to save disk/memory
export_drop <- c(".text_lower", frame_count_cols)
export_cols <- setdiff(names(full_corpus), export_drop)

saveRDS(full_corpus[, export_cols],     file.path(OUTPUT_DIR, "catholic_media_full_corpus.rds"))
saveRDS(framed_corpus[, export_cols],   file.path(OUTPUT_DIR, "catholic_media_contested_corpus.rds"))
saveRDS(catholic_corpus[, export_cols], file.path(OUTPUT_DIR, "catholic_media_catholic_corpus.rds"))
saveRDS(catholic_framed[, export_cols], file.path(OUTPUT_DIR, "catholic_media_catholic_contested.rds"))

log_msg("RDS files saved")

# Excel summary
wb <- createWorkbook()

addWorksheet(wb, "Corpus Overview")
overview <- tibble(
  Metric = c("Total web records", "Records with any frame", "Catholic media records",
             "Catholic framed records", "Date range start", "Date range end",
             "Unique sources", "Unique Catholic sources"),
  Value = c(
    nrow(full_corpus), nrow(framed_corpus),
    nrow(catholic_corpus), nrow(catholic_framed),
    as.character(min(full_corpus$DATE)), as.character(max(full_corpus$DATE)),
    n_distinct(full_corpus$FROM),
    n_distinct(catholic_corpus$FROM)
  )
)
writeData(wb, "Corpus Overview", overview)

addWorksheet(wb, "Media Types")
writeData(wb, "Media Types",
  full_corpus |> count(media_type, sort = TRUE) |> mutate(pct = round(n / sum(n) * 100, 2))
)

addWorksheet(wb, "Catholic Subcategories")
writeData(wb, "Catholic Subcategories",
  catholic_corpus |> count(catholic_subcategory, sort = TRUE) |> mutate(pct = round(n / sum(n) * 100, 2))
)

addWorksheet(wb, "Frame Prevalence")
writeData(wb, "Frame Prevalence",
  full_corpus |>
    summarise(across(all_of(frame_bool_cols), ~sum(.x, na.rm = TRUE))) |>
    pivot_longer(everything(), names_to = "frame", values_to = "count") |>
    mutate(frame = str_remove(frame, "frame_"), pct = round(count / nrow(full_corpus) * 100, 2)) |>
    arrange(desc(count))
)

addWorksheet(wb, "Narrative Phases")
writeData(wb, "Narrative Phases",
  full_corpus |> count(narrative_phase) |> mutate(pct = round(n / sum(n) * 100, 2))
)

saveWorkbook(wb, file.path(OUTPUT_DIR, "catholic_media_summary_stats.xlsx"), overwrite = TRUE)

log_msg("Excel summary saved")
log_msg("Pipeline complete")
log_msg(paste("All outputs in:", normalizePath(OUTPUT_DIR)))