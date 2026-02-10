# Disinformation Narratives in Croatian Catholic Media (2021-2024)

Computational analysis of narrative framing in Croatian Catholic web media. This project examines how Catholic media outlets frame contested topics and measures structural proximity to disinformation narratives using dictionary-based methods on a corpus of 443,000+ web articles.

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
│   ├── 02_analysis.qmd            # Exploratory analysis (Croatian)
│   ├── 03_framing_paper.qmd       # Paper 1: Narrative framing comparison
│   ├── 04_disinfo_paper.qmd       # Paper 2: Disinfo proximity index (NPI)
│   ├── 05_engagement_paper.qmd    # Paper 3: Engagement & amplification
│   └── references.bib             # Shared bibliography
├── CLAUDE.md                      # AI assistant instructions
├── .gitignore
└── README.md
```

## Data

### Source
Raw data comes from the **Determ** platform (formerly Mediatoolkit), which monitors Croatian digital media. The original dataset contains ~25 million records; this project uses the web-only subset (~443K articles after cleaning).

### Corpus Files (not in repo)
The `.rds` corpus files are too large for GitHub (~1.8 GB total):
- `catholic_media_full_corpus.rds` (883 MB) - Full web corpus
- `catholic_media_contested_corpus.rds` (716 MB) - Articles with any frame detected
- `catholic_media_catholic_corpus.rds` (148 MB) - Catholic media only
- `catholic_media_catholic_contested.rds` (127 MB) - Catholic media with frames

To regenerate these, run `code/01_data_preparation.R` with access to the source data. Set the `DIGIKAT_DATA_PATH` environment variable to point to `merged_comprehensive.rds`, or place it in `data/`.

### Key Variables
| Variable | Description |
|----------|-------------|
| `media_type` | Catholic, Conservative, Liberal, Tabloid, Regional, Business, Other |
| `catholic_subcategory` | Official Church, Catholic Radio, Catholic Portals, Catholic Aligned |
| `frame_*` | 8 binary frame indicators (see below) |
| `actor_*` | 7 binary actor indicators |
| `disinfo_alignment_norm` | Narrative Proximity Index (0-100) |
| `narrative_phase` | 6 chronological periods (COVID Peak through Election 2024) |
| `INTERACTIONS` | Engagement count |

### Narrative Frames
| Frame | Description |
|-------|-------------|
| MORAL_DECAY | Moral decline, decadence, secularization |
| FOREIGN_THREAT | External imposition (EU, Soros, globalism) |
| INSTITUTIONAL_DISTRUST | Corruption, manipulation, deep state |
| TRADITIONAL_VALUES | Family, faith, tradition, homeland |
| SOVEREIGNTY | National sovereignty, self-determination |
| CONSPIRACY | Hidden agendas, Big Pharma, Great Reset |
| FAITH_DEFENCE | Persecution of Christians, attacks on Church |
| MEDIA_CRITIQUE | Mainstream media bias, fake news, censorship |

## Papers

Three interconnected research papers, each as a Quarto document:

1. **Framing Paper** (`03_framing_paper.qmd`): Comparative analysis of narrative frames across media types. Logistic regression models. Key finding: Catholic media are not monolithic - Official Church vs Catholic Aligned portals use qualitatively different framing strategies.

2. **Disinfo Paper** (`04_disinfo_paper.qmd`): Develops and tests the Narrative Proximity Index (NPI). Robustness analysis with 5 weight specifications. Network analysis of frame co-occurrence. Sensitivity analysis on classification boundaries.

3. **Engagement Paper** (`05_engagement_paper.qmd`): Tests whether frames structurally close to disinformation ecosystems generate more engagement. Negative binomial regression. Separate models for Catholic vs. other media.

## Setup

### Requirements
- R >= 4.1
- Key packages: `dplyr`, `tidyr`, `stringr`, `stringi`, `lubridate`, `ggplot2`, `scales`, `patchwork`, `knitr`, `kableExtra`, `broom`, `MASS`, `igraph`, `quanteda`, `here`
- Quarto CLI for rendering papers

### Running
```r
# Install here package for project-relative paths
install.packages("here")

# 1. Data preparation (requires source data)
source("code/01_data_preparation.R")

# 2. Render any paper
quarto::quarto_render("papers/03_framing_paper.qmd")
```

## Language

Research content (papers, variable labels, frame dictionaries) is in **Croatian**. Code comments and documentation are in **English**.

## License

Research project - not yet published. Contact authors before use.
