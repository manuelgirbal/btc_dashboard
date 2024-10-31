# btc_dashboard

A bitcoin dashboard using R, Shiny and Quarto

Find it [here](https://manuelgg.shinyapps.io/btc_dashboard/)


## About this project

- This project uses [renv](https://cran.r-project.org/web/packages/renv/index.html) R package for better environment reproducibility. 
    - After downloading this repository for the first time, run `renv::restore()` in your R console to install the required packages. 
    - If you install new packages with `renv::install()` or update existing ones with `renv::update()`, remember to run `renv::snapshot()` before committing and ending your session.
    - If you're working between different computers, it might be useful to run `renv::status()` each time you start your session.
- APIs consumed:
    - [Bitnodes](https://bitnodes.io/)
    - [Blockchain.info](https://blockchain.info/)
- To render the dashboard from CLI, run `quarto serve .\btc_dashboard.qmd` from the root directory (you'll have to have [Quarto](https://quarto.org/) installed).
- To deploy on [shinyapps.io](https://www.shinyapps.io/) run `rsconnect::deployApp()` (you'll have to [setup](https://shiny.posit.co/r/articles/share/shinyapps/) your account and token first)