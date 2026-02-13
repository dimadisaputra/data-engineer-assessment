BUSINESS MONITORING DASHBOARD PROPOSAL: RETAIL OPERATIONS & INVENTORY HEALTH
----------------------------------------------------------------------------

This dashboard aims to synchronize sales data with inventory movements to optimize operational efficiency, minimize losses, and protect cash flow.

### KEY COMPONENTS & VISUALIZATIONS

**1\. Inventory Turnover Ratio**

-   **Description:** Measures how frequently inventory is sold and replaced over a specific period, segmented by product hierarchy (Category L1/L2).

-   **Decision Impact:** Enables the procurement team to distinguish **"Fast-Moving"** goods that require aggressive restocking from **"Slow-Moving"** items that may need promotional clearance to free up working capital.

**2\. Wastage & Expiry Heatmap**

-   **Description:** Visualizes the total financial loss (Total Cost) attributed to products marked with the 'EXP' (Expired) movement status.

-   **Decision Impact:** Pinpoints specific branches or categories with high spoilage rates. This allows management to investigate handling issues for perishable goods or inaccuracies in demand forecasting for specific locations.

**3\. Profit Margin Analysis by Category**

-   **Description:** Correlates revenue data (from sales line items) against the Cost of Goods Sold (COGS) derived from the product hierarchy unit costs.

-   **Decision Impact:** Identifies which categories drive actual bottom-line profit rather than just top-line volume. This data is critical for pricing strategies and optimizing shelf-space allocation.

**4\. Stock-out Risk Alert**

-   **Description:** A proactive list of products where the current balance (Calculated as: $Sum(IN) - Sum(OUT) - Sum(EXP)$) has fallen below the defined `minimum_stock` threshold.

-   **Decision Impact:** Provides branch managers with actionable notifications to trigger reorders before potential sales are lost.

* * * * *

### STRATEGIC VALUE

Retail businesses operate on thin margins where efficiency is everything. This dashboard moves beyond simple "Sales Tracking" by integrating **Wastage Impact** and **Capital Efficiency (Turnover)**. By viewing these metrics in a single pane of glass, stakeholders can shift from reactive firefighting to proactive inventory management, ultimately driving higher profitability.