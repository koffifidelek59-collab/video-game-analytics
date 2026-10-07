// Power Query (M) of Video_Game_Analytics_Dashboard.pbit
// Parameter DataFolder = folder data\processed\ of the project (with final backslash)

// ---- Games
let
    Source = Csv.Document(File.Contents(DataFolder & "video_games_clean.csv"), [Delimiter = ",", Columns = 25, Encoding = 65001, QuoteStyle = QuoteStyle.Csv]),
    #"Promoted Headers" = Table.PromoteHeaders(Source, [PromoteAllScalars = true]),
    #"Blank As Null" = Table.TransformColumns(#"Promoted Headers", {{"Game_ID", each if _ = "" then null else _}, {"Year", each if _ = "" then null else _}, {"Critic_Count", each if _ = "" then null else _}, {"User_Count", each if _ = "" then null else _}, {"Critic_Band_Order", each if _ = "" then null else _}, {"NA_Sales", each if _ = "" then null else _}, {"EU_Sales", each if _ = "" then null else _}, {"JP_Sales", each if _ = "" then null else _}, {"Other_Sales", each if _ = "" then null else _}, {"Global_Sales", each if _ = "" then null else _}, {"Critic_Score", each if _ = "" then null else _}, {"User_Score", each if _ = "" then null else _}, {"User_Score_100", each if _ = "" then null else _}}),
    #"Changed Type" = Table.TransformColumnTypes(#"Blank As Null", {{"Game_ID", Int64.Type}, {"Name", type text}, {"Platform", type text}, {"Year", Int64.Type}, {"Genre", type text}, {"Publisher", type text}, {"NA_Sales", type number}, {"EU_Sales", type number}, {"JP_Sales", type number}, {"Other_Sales", type number}, {"Global_Sales", type number}, {"Critic_Score", type number}, {"Critic_Count", Int64.Type}, {"User_Score", type number}, {"User_Count", Int64.Type}, {"Developer", type text}, {"ESRB_Rating", type text}, {"Platform_Name", type text}, {"Manufacturer", type text}, {"Platform_Type", type text}, {"Decade", type text}, {"User_Score_100", type number}, {"Critic_Band", type text}, {"Critic_Band_Order", Int64.Type}, {"Sales_Tier", type text}}, "en-US"),
    #"Renamed Columns" = Table.RenameColumns(#"Changed Type", {{"Game_ID", "Game ID"}, {"NA_Sales", "NA Sales"}, {"EU_Sales", "EU Sales"}, {"JP_Sales", "JP Sales"}, {"Other_Sales", "Other Sales"}, {"Global_Sales", "Global Sales"}, {"Critic_Score", "Critic Score"}, {"Critic_Count", "Critic Count"}, {"User_Score", "User Score"}, {"User_Count", "User Count"}, {"ESRB_Rating", "ESRB Rating"}, {"Platform_Name", "Platform Name"}, {"Platform_Type", "Platform Type"}, {"User_Score_100", "User Score x10"}, {"Critic_Band", "Critic Band"}, {"Critic_Band_Order", "Critic Band Order"}, {"Sales_Tier", "Sales Tier"}})
in
    #"Renamed Columns"

// ---- Regional Sales
let
    Source = Csv.Document(File.Contents(DataFolder & "regional_sales.csv"), [Delimiter = ",", Columns = 4, Encoding = 65001, QuoteStyle = QuoteStyle.Csv]),
    #"Promoted Headers" = Table.PromoteHeaders(Source, [PromoteAllScalars = true]),
    #"Changed Type" = Table.TransformColumnTypes(#"Promoted Headers", {{"Game_ID", Int64.Type}, {"Region", type text}, {"Sales", type number}, {"Region_Order", Int64.Type}}, "en-US"),
    #"Renamed Columns" = Table.RenameColumns(#"Changed Type", {{"Game_ID", "Game ID"}, {"Region_Order", "Region Order"}})
in
    #"Renamed Columns"

// ---- PS4 XOne
let
    Source = Csv.Document(File.Contents(DataFolder & "ps4_xone_clean.csv"), [Delimiter = ",", Columns = 10, Encoding = 65001, QuoteStyle = QuoteStyle.Csv]),
    #"Promoted Headers" = Table.PromoteHeaders(Source, [PromoteAllScalars = true]),
    #"Blank As Null" = Table.TransformColumns(#"Promoted Headers", {{"Year", each if _ = "" then null else _}}),
    #"Changed Type" = Table.TransformColumnTypes(#"Blank As Null", {{"Game", type text}, {"Platform", type text}, {"Year", Int64.Type}, {"Genre", type text}, {"Publisher", type text}, {"NA", type number}, {"EU", type number}, {"JP", type number}, {"Other", type number}, {"Global", type number}}, "en-US")
in
    #"Changed Type"

// ---- PS4 XOne Regions
let
    Source = #"PS4 XOne",
    Kept = Table.SelectColumns(Source, {"Game", "Platform", "NA", "EU", "JP", "Other"}),
    Unpivoted = Table.UnpivotOtherColumns(Kept, {"Game", "Platform"}, "Region Code", "Sales"),
    Region = Table.AddColumn(Unpivoted, "Region", each if [Region Code] = "NA" then "North America" else if [Region Code] = "EU" then "Europe" else if [Region Code] = "JP" then "Japan" else "Other", type text),
    Result = Table.TransformColumnTypes(Table.SelectColumns(Region, {"Game", "Platform", "Region", "Sales"}), {{"Sales", type number}})
in
    Result

// ---- Cleaning Log
let
    Source = Csv.Document(File.Contents(DataFolder & "cleaning_log.csv"), [Delimiter = ",", Columns = 6, Encoding = 65001, QuoteStyle = QuoteStyle.Csv]),
    #"Promoted Headers" = Table.PromoteHeaders(Source, [PromoteAllScalars = true]),
    #"Changed Type" = Table.TransformColumnTypes(#"Promoted Headers", {{"Step", Int64.Type}, {"Name", type text}, {"Action", type text}, {"Rows Affected", Int64.Type}, {"Rows After", Int64.Type}, {"Units After (M)", type number}}, "en-US")
in
    #"Changed Type"
