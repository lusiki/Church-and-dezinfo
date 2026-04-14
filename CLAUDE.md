# CLAUDE.md - AI Assistant Instructions

## Project Overview

Research project analyzing **Catholic media and Christian democratic discourse in the Croatian digital media sphere (2021-2026)**. Uses dictionary based content analysis on approximately 443K web articles from the Determ (DigiKat) monitoring platform. Two research papers examine (1) narrative framing in Catholic web media and (2) composition of Christian democratic sociopolitical discourse.

## Architecture

```
code/01_data_preparation.R  → data/*.rds     → papers/*.qmd
(ETL pipeline)                (4 corpora)      (2 papers)
```

- **Language**: R (tidyverse style). Papers are Quarto (.qmd) with embedded R code chunks.
- **Paths**: All paths use `here::here()` relative to project root. No hardcoded paths.
- **Data**: `.rds` files are gitignored (1.8 GB total). Regenerate via `code/01_data_preparation.R`.

## Key Concepts

### Corpora (in data/)
| File | Description | ~Size |
|------|-------------|-------|
| `catholic_media_full_corpus.rds` | All web articles (443K rows) | 883 MB |
| `catholic_media_contested_corpus.rds` | Articles with any frame (311K) | 716 MB |
| `catholic_media_catholic_corpus.rds` | Catholic media only (93K) | 148 MB |
| `catholic_media_catholic_contested.rds` | Catholic + framed (71K) | 127 MB |

### Media Classification (7 types)
- **Catholic** (92,915 articles): Official Church (IKA, Glas Koncila), Catholic Radio, Catholic Portals (bitno.net), Catholic Aligned (narod.hr, dnevno.hr)
- **Conservative**: vecernji, hrt.hr, nacional
- **Liberal**: index.hr, telegram.hr, n1.hr
- **Tabloid**: 24sata, jutarnji
- **Regional**: slobodnadalmacija, novilist
- **Business**: poslovni, lider.hr
- **Other**: everything else (256K, largest category)

**Critical distinction**: "Official Church" vs "Catholic Aligned" is the most analytically important boundary in Paper 1.

### 8 Narrative Frames (binary columns `frame_*`)
Detected via Croatian language keyword dictionaries in `code/01_data_preparation.R` (lines 241-326):

| Frame | Croatian keywords (examples) |
|-------|------------------------------|
| MORAL_DECAY | moralni pad, dekadencija, kultura smrti |
| FOREIGN_THREAT | nametanje, soros, globalizam |
| INSTITUTIONAL_DISTRUST | manipulacija, duboka država, propaganda |
| TRADITIONAL_VALUES | tradicija, obitelj, vjera, domovina |
| SOVEREIGNTY | suverenitet, neovisnost, volja naroda |
| CONSPIRACY | zavjera, big pharma, great reset |
| FAITH_DEFENCE | kršćanofobija, progon kršćana |
| MEDIA_CRITIQUE | mainstream mediji, fake news, pristranost |

### Narrative Proximity Index (NPI)
Composite index: `2*CONSPIRACY + 1.5*FOREIGN_THREAT + 1.5*INSTITUTIONAL_DISTRUST + 1*MEDIA_CRITIQUE`, normalized 0 to 100. Stored as `disinfo_alignment_norm`. Used in Paper 1 context for internal analytical purposes.

### RSP Paper Dictionaries (Paper 2)
- **Dictionary A (doctrinal social policy)**: subsidiarity, solidarity, personalism, common good, papal encyclicals, labour rights, family policy instruments
- **Dictionary B (cultural identity)**: national identity, tradition, family values, faith in public space, moral vocabulary
- **SPS Index**: Share of Dictionary A hits in total (A + B) hits per article

### 7 Actor Categories (binary columns `actor_*`)
CHURCH, GOVERNMENT, EU_ACTORS, NGO_CIVIL, SCIENTISTS, MEDIA_ACTORS, FAMILY_ORGS

### 6 Narrative Phases
1. COVID Peak (early 2021)
2. Post Vaccine Debate (mid 2021 to Feb 2022)
3. Ukraine and Energy Crisis (Feb 2022 to Oct 2022)
4. Euro Adoption (Oct 2022 to Jan 2023)
5. Culture Wars Period (Jan 2023 to Jan 2024)
6. Election Run up 2024 (Jan 2024+)

## Papers

### Paper 1: Narrative Framing (`papers/03_framing_paper_2.qmd`)
- **Title**: Tko govori iz katoličkoga medijskog prostora (2021-2026)
- **RQs**: Frame distribution across media types, narrative packages (co occurrence), internal diversity of Catholic media sphere (official vs aligned)
- **Methods**: Proportion tests, logistic regression with robust standard errors (`frame ~ media_type + phase + log(word_count)`), conditional co occurrence matrices, dictionary validation with precision and recall
- **Key packages**: `broom`, `sandwich`, `lmtest`, `flextable`
- **Journal target**: Nova Prisutnost

### Paper 2: Christian Democratic Discourse (`papers/rsp_paper_revised.qmd`)
- **Title**: Sadržaj ili identitet? Demokršćanski socijalnopolitički diskurs u hrvatskom digitalnom medijskom prostoru (2021-2025)
- **RQs**: Prevalence of substantive social policy vs cultural identity register, SPS differences across discursive categories, temporal trends, engagement association
- **Methods**: Fractional logistic regression with clustered standard errors, SPS index, negative binomial engagement models, temporal trend analysis
- **Key packages**: `broom`, `sandwich`, `lmtest`, `MASS`
- **Journal target**: Revija za socijalnu politiku

## Common Patterns

### R code conventions
- Packages auto installed if missing (for/require/install pattern)
- `options(dplyr.summarise.inform = FALSE, scipen = 999)`
- Theme: `theme_minimal(base_size = 11)` with bold titles, bottom legend, black and white style
- Frame columns selected via `grep("^frame_", names(data), value = TRUE)`

### Known issues
- `02_analysis.qmd` references `sentiment_score`, `emotional_intensity`, `topic_*` columns that do not exist in the current data pipeline (sentiment/topic detection was removed in optimization). This file needs updating if rendered.
- Catholic Radio subcategory has only 4 articles, effectively negligible.
- Old papers (03_framing_paper.qmd, 04_disinfo_paper.qmd, 05_engagement_paper.qmd) are superseded by the two current papers but remain in the repository for reference.

## Editing Guidelines

- **Croatian text** in papers is research content. Preserve it. Do not translate unless asked.
- **Frame dictionaries** (lines 241-326 in `01_data_preparation.R`) are the analytical core. Changes here affect all downstream analyses.
- **RSP dictionaries** are defined within `rsp_paper_revised.qmd` itself, not in the shared pipeline.
- When adding new frames/actors: add to dictionaries, re run pipeline, update all papers that reference frame/actor columns.
- The `here` package resolves paths relative to the project root (where `.here` or `.git` exists).

## Build Commands

```bash
# Render a specific paper
quarto render papers/03_framing_paper_2.qmd
quarto render papers/rsp_paper_revised.qmd

# Re-run data pipeline (requires source data)
Rscript code/01_data_preparation.R
```
