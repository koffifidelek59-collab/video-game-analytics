# Video Game Analytics Dashboard: open, check and adjust

The dashboard is delivered as the template `Video_Game_Analytics_Dashboard.pbit`. It loads the cleaned tables produced by `Video-Game-Analytics.ipynb` from `data/processed/`, so that every number of the dashboard is the number of the notebook. This guide explains how to open it, how it is built and how to check it.

## 1. Open the dashboard

1. Get the project: `git clone https://github.com/koffifidelek59-collab/video-game-analytics.git` (or *Code → Download ZIP* on GitHub, then extract). The four tables are in `data\processed\`: `video_games_clean.csv`, `regional_sales.csv`, `ps4_xone_clean.csv`, `cleaning_log.csv`.
2. Double-click `Video_Game_Analytics_Dashboard.pbit` in Power BI Desktop. The window **DataFolder** proposes `C:\video-game-analytics\data\processed\`, which is right if the project is in `C:\video-game-analytics\`. Otherwise paste the full path of the project's `data\processed\` folder **with the final backslash**, then **Load**.
3. If Power BI asks about privacy levels, choose **Organizational** (or File → Options → Current file → Privacy → *Ignore the privacy levels*).
4. Accept the two custom visuals (WordCloud, Scroller) if asked.
5. **File → Save as → `Video_Game_Analytics_Dashboard.pbix`** in the same `powerbi` folder.

The load takes a few seconds. To change the folder later: Home → Transform data → Edit parameters → DataFolder.

## 2. Data pipeline (Home → Transform data)

The cleaning itself is done and documented in the notebook (sections 7 and 8); Power Query reads its outputs and only types and renames the columns.

| Query | Loaded | Role |
|---|---|---|
| `DataFolder` | parameter | folder `data\processed\` |
| `Games` | yes | `video_games_clean.csv`: one row per release (16,715), 25 columns; empty cells read as null; names with spaces |
| `Regional Sales` | yes | `regional_sales.csv`: four rows per release (66,860), one per region |
| `PS4 XOne` | yes | `ps4_xone_clean.csv`: 1,135 PS4 and Xbox One releases with sales (later snapshot) |
| `PS4 XOne Regions` | yes | the same, unpivoted by region (Table.UnpivotOtherColumns) |
| `Cleaning Log` | yes | `cleaning_log.csv`: the cleaning steps with rows and units after each step |

The full M code is in `PowerQuery_pipeline.m`.

## 3. Model view

| Relationship | Cardinality | Cross filter |
|---|---|---|
| `Regional Sales[Game ID]` → `Games[Game ID]` | many to one | Single (the Games slicers filter the region visuals) |

`PS4 XOne`, `PS4 XOne Regions` and `Cleaning Log` are independent tables (another source and the log). `Games[Critic Band]` is sorted by `Critic Band Order`, `Regional Sales[Region]` by `Region Order`. The 22 measures are in `DAX_measures.dax`; the main ones:

| Measure | DAX (short) |
|---|---|
| Total Games | `DISTINCTCOUNT ( Games[Name] )`: distinct titles |
| Total Releases | `COUNTROWS ( Games )`: game × platform |
| Total Sales (M) | `SUM ( Games[Global Sales] )`, millions of units |
| Top Genre / Top Platform / Top Publisher | `TOPN ( 1, VALUES ( ... ), [Total Sales (M)] )`: leader in the current filter context |
| Hit Rate (1M+) | share of releases with at least 1 M units |
| Region Share, Genre Share in Region | shares computed with `ALLSELECTED` |

## 4. Pages

| Page | Visuals (question of the brief) |
|---|---|
| Overview | 6 KPI cards (Total Games, Total Releases, Total Sales, Top Genre, Top Platform, Top Publisher) · sales trend (Q5) · region donut (Q6) · sales by genre (Q1), top 10 platforms (Q2), top 10 publishers (Q3) · scrolling best sellers (Q4) |
| Genres & Platforms | releases by genre (Q1) · average and median units per release by genre · units per year by manufacturer (Q5) · top 12 platforms (Q2) |
| Publishers & Games | top 10 publishers (Q3) · releases vs average units per release (top 25 publishers) · top 10 releases (table) and top 10 games, all platforms (Q4) |
| Regions | region donut · region share by year (100 % stacked) · genre share inside each region · units by region (Q6) |
| Ratings & Sales | 4 cards · median units by critic band · average units at each critic score with trend line · critics vs players · median units by ESRB rating (Q7) |
| PS4 & Xbox One | 4 cards · region donut · top 10 games · units by genre · units by year and console |
| Insights | the 9 insights and the recommendations |
| Data Quality | pipeline summary and the cleaning log |

Four slicers are synchronised across the analysis pages: **Year of release** (range), **Genre**, **Manufacturer**, **Platform**. Time charts start in 1980 (visual filter `Year >= 1980`), so the 272 releases without a reliable year are excluded there only.

## 5. Adjust a visual

- **Change a Top N:** select the visual → Filters pane → Top N filter → change the number.
- **Change colours:** View → Themes → Customize current theme (theme `Neon_Arcade`: cyan `#22D3EE`, magenta `#EC4899`, violet `#8B5CF6`, amber `#F59E0B`, lime `#84CC16`, background `#070A1F`); the theme file is `vg_theme.json`. The decor (background, header, panels, KPI cards) are images in the report resources: a visual and its panel move together if both are selected (Ctrl + click).
- **Move or resize:** drag the visual and its panel image together (select both with Ctrl).
- **Data folder moved:** Home → Transform data → Edit parameters → DataFolder.

## 6. Check before submitting (no filter)

| Check | Expected value |
|---|---|
| Total Games / Total Releases | 11,563 / 16,715 |
| Total Sales | 8,917.9 M |
| Top Genre / Top Platform / Top Publisher | Action / PlayStation 2 / Nintendo |
| Region donut | North America 49.4 %, Europe 27.2 %, Japan 14.6 %, Other 8.9 % (total 8,913.6 M: the regional values are rounded to 0.01 M in the source) |
| Sales trend | peak in 2008 (671.8 M) |
| Ratings & Sales cards | 8,135 scored releases · avg critic score 69.0 · avg user score x10 71.3 · median 0.24 M |
| Median units, critic band 90+ / < 50 | 1.54 M / 0.12 M |
| PS4 & Xbox One cards | 1,135 releases · 864.7 M · 0.76 M · Japan 4.1 % |
| Data Quality | 10 steps; 16,719 → 16,715 rows; 8,920.30 → 8,917.88 M units |
| Genre = Shooter | 1,323 releases, 1,052.9 M; top publisher Activision; top platform Xbox 360 |
| Manufacturer = Nintendo | 6,271 releases, 3,499.8 M; top platform Wii |
| Year 2010-2016 | 5,276 releases, 2,545.1 M; top platform PlayStation 3; top publisher Electronic Arts |

## 7. Captures for the report

Once the dashboard is checked, export one capture per page (File → Export → PDF, or a screenshot of each page at full screen) and name them `p1_overview.png`, `p2_genres_platforms.png`, `p3_publishers_games.png`, `p4_regions.png`, `p5_ratings_sales.png`, `p6_ps4_xbox_one.png`, `p7_insights.png`, `p8_data_quality.png` in `figures/dashboard/`.
