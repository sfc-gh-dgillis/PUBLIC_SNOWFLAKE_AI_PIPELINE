# Cortex AI for Financial Services

### Author
John Heisler

The intent of these assets is both instructional and functional. In `FSI_Cortex_AI_Pipeline.ipynb` and `FSI_Cortex_Search.ipynb` we aim to demonstrate the art of the possible with two of our features, [Cortex Complete](https://docs.snowflake.com/en/sql-reference/functions/complete-snowflake-cortex) and [Cortex Search](https://docs.snowflake.com/en/user-guide/snowflake-cortex/cortex-search/cortex-search-overview), respectively.

In `FSI_Cortex_AI_Pipeline_Industrialization.ipynb`, we take the functional elements built in `FSI_Cortex_AI_Pipeline.ipynb` and industrialize them toward an enterprise-ready AI pipeline.

## Suggested Learning Path

1. Run Set Up SQL Script `1_SQL_SETUP_FOMCl.sql`
	1. **Note**: `SYSADMIN` or a role with `CREATE WAREHOUSE`, `CREATE DATABASE` privileges are required. For the final statement `CREATE OR REPLACE EXTERNAL ACCESS INTEGRATION`, the `ACCOUNTADMIN` role is required.
2. Load FOMC documents in the `FOMC_DOCS` directory into the `fed_logic` stage via snowsight.
	1. See [Loading Files into Stage through Snowflake UI — The Complete Guide](https://snowflakewiki.medium.com/loading-files-into-stage-through-snowflake-ui-the-complete-guide-321b135f6175)
3. Step through `FSI_Cortex_AI_Pipeline.ipynb`
4. Step through `FSI_Cortex_Search.ipynb`
5. Read our [AI-Infused Pipelines with Snowflake Cortex Medium Article](https://medium.com/snowflake/ai-infused-pipelines-with-snowflake-cortex-6a7954f2078d) and step through `FSI_Cortex_AI_Pipeline_Industrialization.ipynb`

I hope you learn as much as I did building these!
  
John Heisler
