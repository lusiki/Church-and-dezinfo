# Catholic Media and Christian Democratic Discourse in Croatia (2021-2026)

Computational analysis of narrative framing and ideological composition in the Croatian digital media sphere. This project uses dictionary based content analysis on a large corpus of web articles from the Determ (DigiKat) monitoring platform. Two research papers examine (1) narrative frames in Catholic web media and (2) the composition of Christian democratic sociopolitical discourse across media types.

## Project Structure

```
.
├── code/
│   └── 01_data_preparation.R     # Data pipeline: loading, cleaning, frame/actor detection
├── data/
│   ├── catholic_media_summary_stats.xlsx   # Summary statistics (tracked in git)
│   ├── data_preparation_log.txt            # Pipeline execution log
│   └── *.rds                               # Corpus files (NOT tracked - too large)
├── papers/
│   ├── 03_framing_paper_2.qmd    # Paper 1: Narrative framing in Catholic media
│   ├── rsp_paper_revised.qmd     # Paper 2: Christian democratic discourse (RSP)
│   └── references.bib            # Shared bibliography
├── CLAUDE.md                     # AI assistant instructions
├── .gitignore
└── README.md
```

---

## Papers

This project produces two research papers. Paper 1 maps how Catholic media frame contested topics and identifies internal diversity within the Catholic media sphere. Paper 2 asks whether the broader digital public sphere still carries substantive Christian democratic social policy content or has shifted to cultural identity signalling. Together they address the same underlying question from two directions: what does the Catholic and Christian democratic voice in Croatian media actually say, and how has it changed.

### Paper 1: Narrative Framing in Croatian Catholic Web Media

**[View rendered analysis](https://raw.githack.com/lusiki/Church-and-dezinfo/main/papers/03_framing_paper_2.html)** | [Source](papers/03_framing_paper_2.qmd)

Every news article makes choices about what to emphasize. An article about migration can emphasize sovereignty, foreign threat, traditional values, or institutional distrust. These choices are called frames. Paper 1 takes a large corpus of web articles covering the period 2021 to 2026, detects which of eight narrative frames are present using a dictionary procedure validated against a manually coded sample, and asks three questions. Do Catholic media differ from other media types in their use of narrative frames after controlling for article length and time period. Which frames cluster into recognisable interpretive packages. And most importantly, how does the internal diversity of the Catholic media sphere manifest, specifically the difference between official ecclesial outlets such as IKA and Glas Koncila and Catholic aligned portals such as narod.hr and dnevno.hr.

The core finding is that Catholic media are not one thing. Official Church outlets and Catholic aligned portals use different narrative strategies, and the difference survives controls for article length and publication period. The official outlets lean toward traditional values, faith defence, and moral decay, which is expected and legitimate for religious media. The aligned portals build a political antagonistic layer on top of a shared affirmative core, activating conspiracy, media critique, sovereignty, and foreign threat frames substantially more often. Counter to public perception, traditional values are activated more frequently by official ecclesial media than by the aligned portals, suggesting that political portals translate the conservative position into a geopolitical and antagonistic vocabulary while abandoning the proper vocabulary of tradition. Conspiratorial and antagonistic frames in the aggregated Catholic sphere are not elevated, which corrects the perception of Catholic media as homogeneously antagonistic.

Co occurrence analysis does not confirm the originally predicted contrast between an affirmative and a defensively antagonistic interpretive package. Instead it reveals a shared affirmative moral and traditional core present in both subspaces and a political antagonistic layer that aligned portals build above that core and that remains marginal in official media. All phi coefficients remain below 0.12, indicating weak systematic tendencies rather than tight nesting.

The discussion situates these findings within the theology of communication, drawing on the pastoral instructions Communio et Progressio (1971) and Aetatis Novae (1992). The central argument is that the empirical diversity within the Catholic media sphere raises an ecclesiological question about the distinction between the institutional voice of the Church and the plural voices of lay communicators who invoke Christian values without ecclesial accountability.

**Methods.** Proportion tests, logistic regression with robust standard errors (frame ~ media_type + narrative_phase + log(word_count)), conditional co occurrence matrices, dictionary validation with precision and recall, formal interaction tests between media type and publication year.

**Journal target.** Nova Prisutnost (primary). Broader fit: European Journal of Communication, Communications: The European Journal of Communication Research, Religion State and Society, Journal of Church and State.

---

### Paper 2: Christian Democratic Discourse in Croatian Digital Media (RSP)

**[View rendered analysis](https://raw.githack.com/lusiki/Church-and-dezinfo/main/papers/rsp_paper_revised.html)** | [Source](papers/rsp_paper_revised.qmd)

The classical European Christian democratic model after 1945 rested on a synthesis of two clusters of ideas. The socioeconomic cluster drew on Catholic social teaching: subsidiarity, solidarity, personalism, common good, dignity of work, just wages, and concrete policies from pension systems to family policy. The cultural moral cluster addressed family, marriage, human life, faith in public space, and national identity. The contemporary thesis of disintegration argues that Christian democratic parties across Europe are asymmetrically abandoning this synthesis. The socioeconomic component weakens while the cultural identity component persists or intensifies.

Paper 2 tests this thesis empirically in the Croatian digital media sphere from 2021 to 2025. Using the DigiKat corpus, it constructs two dictionaries: one for doctrinal social policy vocabulary (subsidiarity, solidarity, labour rights, family policy instruments, papal encyclicals) and one for cultural identity vocabulary (national identity, tradition, family values, faith in public space). The Social Policy Substance Index (SPS) is defined as the share of doctrinal hits in total hits for each article. Posts are classified by which institutional actor they discuss (Church, government, family organizations, civil society, EU, academics, media) using pre computed indicators that identify the actor as the subject of discussion, not as the author of the post.

Results show that the cultural identity register dominates over the substantive social policy register. SPS values differ across discursive categories. There is no upward trend in substantiveness over the period. And the attention economy does not reward substantive content: articles with higher social policy substance are associated with lower public engagement. The findings support the thesis that the classical Christian democratic synthesis is disintegrating in Croatian public discourse. What remains when actors invoke Christian democratic vocabulary is increasingly identity signalling rather than substantive social policy articulation.

The contribution is threefold. Methodologically the paper offers a reproducible measurement instrument for large volumes of Croatian digital text. Empirically it maps the ideological composition of public discourse about social policy across actor categories and time. Theoretically the results provide a direct test of the disintegration thesis in a post communist context with a historically strong Church presence.

**Methods.** Fractional logistic regression with clustered standard errors at the source level, two validated dictionaries (doctrinal social policy and cultural identity), SPS index construction, temporal trend analysis, engagement modelling with negative binomial regression, discursive category classification via pre computed actor indicators.

**Journal target.** Revija za socijalnu politiku (primary). Broader fit: Journal of European Social Policy, West European Politics, Social Policy & Administration.

---

### How the Two Papers Relate

Paper 1 establishes the descriptive foundation of the Catholic media sphere: it is internally diverse, with official ecclesial outlets and aligned portals pursuing different narrative strategies. Paper 2 zooms out from Catholic media specifically to the broader digital public sphere and asks whether the Christian democratic tradition, of which Catholic media are one voice among many, still carries substantive social policy content or has become primarily a vehicle for cultural identity positioning. Together they document a double displacement: within Catholic media, official ecclesial framing gives way to political antagonism in aligned portals; across the broader media sphere, doctrinal substance gives way to identity signalling.

---

## Data

### Source
Raw data comes from the **Determ** platform (DigiKat corpus), which monitors Croatian digital media. The original dataset contains approximately 25 million records; this project uses the web only subset (approximately 443K articles after cleaning).

### Corpus Files (not in repo)
The .rds corpus files are too large for GitHub (approximately 1.8 GB total):

- `catholic_media_full_corpus.rds` (883 MB) Full web corpus (443K articles)
- `catholic_media_contested_corpus.rds` (716 MB) Articles with any frame detected (311K)
- `catholic_media_catholic_corpus.rds` (148 MB) Catholic media only (93K)
- `catholic_media_catholic_contested.rds` (127 MB) Catholic media with frames (71K)

To regenerate, run `code/01_data_preparation.R` with access to the source data. Set the `DIGIKAT_DATA_PATH` environment variable to point to `merged_comprehensive.rds`, or place it in `data/`.

### Key Variables

| Variable | Description |
|----------|-------------|
| `media_type` | Catholic, Conservative, Liberal, Tabloid, Regional, Business, Other |
| `catholic_subcategory` | Official Church, Catholic Radio, Catholic Portals, Catholic Aligned |
| `frame_*` | 8 binary frame indicators (see below) |
| `actor_*` | 7 binary actor indicators (CHURCH, GOVERNMENT, EU_ACTORS, NGO_CIVIL, SCIENTISTS, MEDIA_ACTORS, FAMILY_ORGS) |
| `disinfo_alignment_norm` | Narrative Proximity Index, 0 to 100 |
| `narrative_phase` | 6 chronological periods (COVID Peak through Election 2024) |
| `INTERACTIONS` | Engagement count |

### Narrative Frames (Paper 1)

| Frame | Description | NPI Weight |
|-------|-------------|------------|
| CONSPIRACY | Hidden agendas, Big Pharma, Great Reset | 2.0 |
| FOREIGN_THREAT | External imposition (EU, Soros, globalism) | 1.5 |
| INSTITUTIONAL_DISTRUST | Corruption, manipulation, deep state | 1.5 |
| MEDIA_CRITIQUE | Mainstream media bias, fake news, censorship | 1.0 |
| MORAL_DECAY | Moral decline, decadence, secularization | |
| TRADITIONAL_VALUES | Family, faith, tradition, homeland | |
| SOVEREIGNTY | National sovereignty, self determination | |
| FAITH_DEFENCE | Persecution of Christians, attacks on Church | |

### Dictionaries (Paper 2)

| Dictionary | Description |
|-----------|-------------|
| Doctrinal social policy (A) | Subsidiarity, solidarity, personalism, common good, papal encyclicals, labour rights, family policy instruments |
| Cultural identity (B) | National identity, tradition, family values, faith in public space, moral vocabulary |

The Social Policy Substance Index (SPS) is defined as the share of Dictionary A hits in the sum of Dictionary A and Dictionary B hits per article.

## Setup

### Requirements
R >= 4.1. Key packages: `dplyr`, `tidyr`, `stringr`, `stringi`, `lubridate`, `ggplot2`, `scales`, `patchwork`, `knitr`, `kableExtra`, `broom`, `MASS`, `sandwich`, `lmtest`, `flextable`, `here`. Quarto CLI for rendering papers.

### Running
```r
# Install here package for project relative paths
install.packages("here")

# 1. Data preparation (requires source data)
source("code/01_data_preparation.R")

# 2. Render any paper
quarto::quarto_render("papers/03_framing_paper_2.qmd")
quarto::quarto_render("papers/rsp_paper_revised.qmd")
```

## Language

Research content (papers, variable labels, frame dictionaries) is in **Croatian**. Code comments and documentation are in **English**.

## License

Research project. Contact authors before use.
