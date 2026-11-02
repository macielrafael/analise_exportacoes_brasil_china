# ==========================================================
# 01_baixar_dados.R
# Objetivo: baixar as exportações brasileiras por país e ano
# (Comex Stat/MDIC) e salvar uma tabela enxuta em dados/
# Rode com o projeto aberto no RStudio (.Rproj)
# ==========================================================

if (!requireNamespace("comexr", quietly = TRUE)) install.packages("comexr")
library(comexr)
library(dplyr)

dir.create("dados", showWarnings = FALSE)

anos <- 2000:2025

# Baixa um ano por vez, com pausas por causa do limite da API.
# Se o arquivo do ano já existe, pula (dá para retomar de onde parou).
baixar_ano <- function(ano) {
  arquivo <- paste0("dados/exp_", ano, ".csv")
  if (file.exists(arquivo)) return(invisible(NULL))
  
  for (tentativa in 1:5) {
    resultado <- tryCatch(
      comex_export(
        start_period = paste0(ano, "-01"),
        end_period   = paste0(ano, "-12"),
        details      = "country"
      ),
      error = function(e) NULL
    )
    if (!is.null(resultado)) {
      write.csv(resultado, arquivo, row.names = FALSE)
      Sys.sleep(5)
      return(invisible(NULL))
    }
    Sys.sleep(15)
  }
  message("Falhou: ", ano)
}

for (a in anos) baixar_ano(a)

# Junta os anos e soma os meses: uma linha por país e ano
exp_pais_ano <- list.files("dados", pattern = "^exp_[0-9]{4}\\.csv$",
                           full.names = TRUE) |>
  lapply(read.csv) |>
  bind_rows() |>
  group_by(year, country) |>
  summarise(fob_usd = sum(metricFOB), kg = sum(metricKG), .groups = "drop")

write.csv(exp_pais_ano, "dados/exportacoes_pais_ano.csv", row.names = FALSE)