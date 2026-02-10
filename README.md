# Disinformation Narratives in Croatian Catholic Media (2021-2024)

Computational analysis of narrative framing in Croatian Catholic web media. This project examines how Catholic media outlets frame contested topics and measures structural proximity to disinformation narratives using dictionary-based methods on a corpus of 443,000+ web articles from the Determ monitoring platform.

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

---

## Papers

This project produces three interconnected research papers. Each paper stands alone for publication, but together they tell one story in three parts: Catholic media use specific frames. Some of those frames structurally resemble disinformation. And the audience rewards them.

### Paper 1: Narrative Framing Comparison

**[View rendered analysis](https://raw.githack.com/lusiki/Church-and-dezinfo/main/papers/03_framing_paper.html)** | [Source](papers/03_framing_paper.qmd)

Every news article makes choices about what to emphasize. An article about migration can emphasize sovereignty ("our borders are being violated"), foreign threat ("Brussels is forcing this on us"), traditional values ("this undermines our way of life"), or institutional distrust ("the government is lying about the numbers"). These choices are called *frames*. Paper 1 takes every web article in the corpus, detects which of eight frames are present, and asks: do Catholic media make different framing choices than liberal, tabloid, conservative, regional and business media?

The answer is yes, but the more interesting finding is that **Catholic media are not one thing**. Official Church outlets like IKA and Glas Koncila frame differently than Catholic-aligned portals like narod.hr and dnevno.hr. The official outlets lean toward traditional values and faith defence, which is expected and legitimate for religious media. The aligned portals lean much more heavily toward institutional distrust, conspiracy, and media critique. The logistic regression confirms these differences hold up after accounting for the fact that longer articles mechanically contain more keywords and that different time periods (COVID, Ukraine war, election) naturally produce different frames.

**Connection to disinformation.** The framing literature since Entman (1993) argues that frames are not neutral: they define problems, assign blame, and suggest solutions. The disinformation literature (Wardle & Derakhshan 2017, Bastos & Tuters 2023) adds that specific frame combinations -- particularly conspiracy + institutional distrust + media critique -- are structural signatures of disinformation ecosystems. Paper 1 does not claim that Catholic media produce disinformation. It maps which frames they use and shows that Catholic-aligned portals use frame combinations that structurally resemble those found in disinformation ecosystems elsewhere, while official Church media do not. This distinction between institutional and non-institutional religious media is the core contribution.

**Methods.** Proportion tests, logistic regression (frame ~ media_type + narrative_phase + log(word_count)), conditional co-occurrence matrices.

**Journal fit.** European Journal of Communication, Journalism & Mass Communication Quarterly, Media Culture & Society, Communications: The European Journal of Communication Research. For post-communist/religious emphasis: Religion State and Society, Journal of Church and State. For computational framing: Political Communication, Communication Methods and Measures.

---

### Paper 2: Structural Proximity to Disinformation (NPI)

**[View rendered analysis](https://raw.githack.com/lusiki/Church-and-dezinfo/main/papers/04_disinfo_paper.html)** | [Source](papers/04_disinfo_paper.qmd)

Paper 1 shows which frames Catholic media use. Paper 2 asks a harder question: if we combine the frames that the literature identifies as characteristic of disinformation ecosystems (conspiracy, foreign threat, institutional distrust, media critique) into a single score, how do different media types compare? And is that comparison robust or does it depend on arbitrary choices we made?

The score is called the **Narrative Proximity Index (NPI)**. Think of it as a thermometer that measures how much an article's narrative structure resembles the structural fingerprint of disinformation. It does not measure whether anything in the article is true or false. An article with a high NPI might be entirely factually correct. It just uses the same narrative building blocks (us vs. them, hidden agendas, institutions are lying, mainstream media cannot be trusted) that disinformation ecosystems typically rely on.

**Robustness testing.** Any composite index involves arbitrary choices about weighting. We gave conspiracy a weight of 2 and media critique a weight of 1, but why? What if we weight them equally? What if we only count conspiracy? The paper runs five different weighting schemes and checks whether the ranking of media types changes. If Catholic media rank third under all five schemes, the finding is robust. If they rank second under one scheme and sixth under another, the finding is fragile and depends on our choices.

**Classification sensitivity.** We classified narod.hr and dnevno.hr as "Catholic Aligned", but a reasonable person could classify them as conservative secular media. The paper runs the entire analysis twice -- once with these portals as Catholic and once as Conservative -- and reports exactly how much the results change. This is methodological honesty that most studies in this space lack, since media classification is one of the most consequential analytical decisions but is usually treated as unproblematic.

**Hierarchical clustering.** If we forget our labels entirely and just group media by how similar their eight-frame profiles are, which media end up in the same cluster? This tells us whether our a priori classification actually corresponds to meaningful differences in narrative strategy or whether some categories we treat as distinct are narratively indistinguishable.

**Connection to disinformation.** The theoretical contribution draws on the emerging consensus that disinformation is better understood as an ecosystem property than a property of individual texts (Benkler et al. 2018, Freelon & Wells 2020). A media outlet can be factually accurate and still operate in a way that structurally feeds into disinformation ecosystems -- by consistently priming institutional distrust and conspiracy frames that make audiences more receptive to actual disinformation when they encounter it elsewhere. The NPI operationalizes this idea. The robustness analysis addresses the criticism (Hameleers 2022, Egelhofer & Lecheler 2019) that disinformation research often relies on ad hoc measures without testing their sensitivity to specification choices.

**Methods.** 5 NPI weight specifications, Kruskal-Wallis tests, pairwise Wilcoxon with BH correction, hierarchical clustering (Ward's method), network analysis (igraph), reclassification sensitivity analysis.

**Journal fit.** Political Communication, Journal of Communication, New Media & Society, Information Communication & Society, Communication Methods and Measures. Policy-oriented: Harvard Kennedy School Misinformation Review, Journal of Online Trust and Safety. European focus: European Journal of Communication, Javnost.

---

### Paper 3: Engagement and Amplification

**[View rendered analysis](https://github.com/lusiki/Church-and-dezinfo/blob/main/papers/05_engagement_paper.html)** | [Source](papers/05_engagement_paper.qmd)

Papers 1 and 2 analyze what media publish. Paper 3 asks what the audience does with it. Specifically: do articles with certain frames get more clicks, comments, and shares? And critically, do articles whose narrative structure is closer to disinformation ecosystems (higher NPI) get rewarded with more engagement?

This matters because of how the internet works. Media outlets that depend on advertising revenue need clicks. Editors and writers learn what works. If conspiracy-framed articles consistently generate 40% more interactions than articles without that frame, there is a financial incentive to produce more of them. Over time, this creates a feedback loop: audiences click on conspiracy content, so editors produce more of it, which normalizes conspiracy framing, which makes audiences expect and seek out more of it.

**Four models.** Model 1 asks which individual frames predict more engagement (each frame gets its own coefficient). Model 2 replaces the eight individual frames with the composite NPI and tests whether the relationship is linear or nonlinear. A convex curve -- where engagement accelerates at high NPI levels -- would be the most concerning finding because it means the most disinformation-adjacent content gets disproportionately rewarded. Model 3 fits separate models for Catholic media and all other media to see whether the same frame generates different levels of engagement depending on who published it. This tests whether Catholic media audiences specifically reward certain frames that audiences of other media do not care about.

**Actor-frame interactions.** The analysis asks whether articles mentioning the Church within a faith defence frame generate different engagement than articles mentioning the Government within an institutional distrust frame. These combinations represent specific narrative situations, and their engagement profiles reveal what the Catholic media audience specifically responds to.

**Connection to disinformation.** Vosoughi et al. (2018) in *Science* showed that false news spreads faster and further than true news. Brady et al. (2017) showed that moral and emotional content gets shared more. Robertson et al. (2023) in *Nature Human Behaviour* showed negativity drives online news consumption. Paper 3 extends this line of research from individual social media posts to structured web articles and from a true/false binary to a continuous measure of narrative proximity to disinformation. The policy implication is direct: if the attention economy structurally rewards disinformation-adjacent narratives, media literacy interventions aimed at audiences are insufficient. The problem requires structural solutions at the level of platform design and media economics (Pennycook & Rand 2021).

**Methods.** Negative binomial regression (MASS::glm.nb), incidence rate ratios, linear vs. quadratic NPI models, separate Catholic/Other subgroup models, actor-frame engagement heatmaps.

**Journal fit.** Nature Human Behaviour (if results are strong), Journal of Communication, Political Communication, New Media & Society, Journal of Quantitative Description: Digital Media, Information Communication & Society, Digital Journalism. Policy: Harvard Kennedy School Misinformation Review.

---

### How the Three Papers Relate

Paper 1 establishes the descriptive foundation: Catholic media frame differently, and the internal split between official and aligned outlets is the key finding. Paper 2 builds on that by asking whether the framing differences translate into measurable structural proximity to disinformation ecosystems, and whether that measurement is trustworthy. Paper 3 closes the loop by asking whether the audience rewards or punishes those narrative choices, which determines whether the ecosystem is self-reinforcing or self-correcting.

---

## Data

### Source
Raw data comes from the **Determ** platform (formerly Mediatoolkit), which monitors Croatian digital media. The original dataset contains ~25 million records; this project uses the web-only subset (~443K articles after cleaning).

### Corpus Files (not in repo)
The `.rds` corpus files are too large for GitHub (~1.8 GB total):
- `catholic_media_full_corpus.rds` (883 MB) -- Full web corpus (443K articles)
- `catholic_media_contested_corpus.rds` (716 MB) -- Articles with any frame detected (311K)
- `catholic_media_catholic_corpus.rds` (148 MB) -- Catholic media only (93K)
- `catholic_media_catholic_contested.rds` (127 MB) -- Catholic media with frames (71K)

To regenerate, run `code/01_data_preparation.R` with access to the source data. Set the `DIGIKAT_DATA_PATH` environment variable to point to `merged_comprehensive.rds`, or place it in `data/`.

### Key Variables
| Variable | Description |
|----------|-------------|
| `media_type` | Catholic, Conservative, Liberal, Tabloid, Regional, Business, Other |
| `catholic_subcategory` | Official Church, Catholic Radio, Catholic Portals, Catholic Aligned |
| `frame_*` | 8 binary frame indicators (see below) |
| `actor_*` | 7 binary actor indicators (CHURCH, GOVERNMENT, EU_ACTORS, NGO_CIVIL, SCIENTISTS, MEDIA_ACTORS, FAMILY_ORGS) |
| `disinfo_alignment_norm` | Narrative Proximity Index, 0-100 |
| `narrative_phase` | 6 chronological periods (COVID Peak through Election 2024) |
| `INTERACTIONS` | Engagement count |

### Narrative Frames
| Frame | Description | NPI Weight |
|-------|-------------|------------|
| CONSPIRACY | Hidden agendas, Big Pharma, Great Reset | 2.0 |
| FOREIGN_THREAT | External imposition (EU, Soros, globalism) | 1.5 |
| INSTITUTIONAL_DISTRUST | Corruption, manipulation, deep state | 1.5 |
| MEDIA_CRITIQUE | Mainstream media bias, fake news, censorship | 1.0 |
| MORAL_DECAY | Moral decline, decadence, secularization | -- |
| TRADITIONAL_VALUES | Family, faith, tradition, homeland | -- |
| SOVEREIGNTY | National sovereignty, self-determination | -- |
| FAITH_DEFENCE | Persecution of Christians, attacks on Church | -- |

The first four frames constitute the NPI. The remaining four are analytically important but not theoretically linked to disinformation ecosystem structures.

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

Research project -- not yet published. Contact authors before use.
