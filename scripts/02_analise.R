# ==========================================================
# 02_analise.R
# Objetivo: calcular a participação dos destinos e o índice
# HHI, e gerar os gráficos do projeto
# ==========================================================

library(dplyr)
library(ggplot2)
library(scales)

dir.create("graficos", showWarnings = FALSE)

# ---------- 1. Tema visual (usado nos 3 gráficos) ----------
tema_portfolio <- function() {
  theme_minimal(base_size = 13) +
    theme(
      plot.title.position   = "plot",
      plot.caption.position = "plot",
      plot.title    = element_text(face = "bold", size = 16, color = "#1f2933",
                                   hjust = 0.5),
      plot.subtitle = element_text(size = 11.5, color = "#52606d",
                                   hjust = 0.5, margin = margin(b = 12)),
      plot.caption  = element_text(size = 8, color = "#7b8794", hjust = 0,
                                   margin = margin(t = 10)),
      axis.title    = element_text(size = 11, color = "#52606d"),
      axis.title.y  = element_text(margin = margin(r = 14)),
      axis.text     = element_text(color = "#52606d"),
      panel.grid.minor   = element_blank(),
      panel.grid.major.x = element_blank(),
      panel.grid.major.y = element_line(color = "#e4e7eb"),
      plot.margin      = margin(15, 20, 10, 15),
      plot.background  = element_rect(fill = "white", color = NA),
      legend.position  = "none"
    )
}

fonte <- "Fonte: Comex Stat/MDIC. Elaboração própria."
pct   <- label_percent(accuracy = 1, decimal.mark = ",")

# ---------- 2. Dados e cálculos ----------
exp_pais_ano <- read.csv("dados/exportacoes_pais_ano.csv")

nomes_pt <- c("United States" = "EUA",
              "Netherlands"   = "Países Baixos",
              "Spain"         = "Espanha")

participacao <- exp_pais_ano |>
  group_by(year) |>
  mutate(share = fob_usd / sum(fob_usd)) |>
  ungroup() |>
  mutate(pais = recode(country, !!!nomes_pt))

hhi <- participacao |>
  group_by(year) |>
  summarise(hhi = round(sum(share^2) * 10000))

write.csv(hhi, "dados/hhi_por_ano.csv", row.names = FALSE)

# ---------- 3. Gráfico 1: participação da China ----------
china <- participacao |> filter(country == "China")
pico  <- china |> slice_max(share, n = 1)

g1 <- ggplot(china, aes(x = year, y = share)) +
  geom_area(fill = "#D1495B", alpha = 0.12) +
  geom_line(linewidth = 1.3, color = "#D1495B") +
  geom_point(data = pico, size = 3.5, color = "#D1495B") +
  geom_text(
    data = pico,
    aes(label = paste0("Pico: ", format(round(share * 100, 1), decimal.mark = ","),
                       "% (", year, ")")),
    vjust = -1.3, size = 3.8, fontface = "bold", color = "#D1495B"
  ) +
  scale_x_continuous(breaks = seq(2000, 2025, 5)) +
  scale_y_continuous(labels = pct, limits = c(0, 0.37),
                     expand = expansion(mult = c(0, 0))) +
  labs(
    title    = "O peso da China nas exportações brasileiras",
    subtitle = "Participação da China no valor total exportado, 2000–2025",
    x = NULL, y = "Participação nas exportações", caption = fonte
  ) +
  tema_portfolio()

ggsave("graficos/01_participacao_china.png", g1,
       width = 9, height = 5.5, dpi = 200)

# ---------- 4. Gráfico 2: principais destinos ----------
top5 <- participacao |>
  filter(year == 2025) |>
  slice_max(share, n = 5)

cores <- c("China"         = "#D1495B",
           "EUA"           = "#2E4057",
           "Argentina"     = "#66A182",
           "Países Baixos" = "#EDAE49",
           "Espanha"       = "#8D96A3")

dados_g2 <- participacao |> filter(country %in% top5$country)

# Posição dos rótulos no fim das linhas, com distância mínima entre eles
# (evita sobreposição; só o texto muda de lugar, não as linhas)
rotulos <- dados_g2 |>
  filter(year == 2025) |>
  arrange(share) |>
  mutate(y_rot = share)

rotulos$y_rot[1] <- rotulos$y_rot[1] - 0.004
for (i in 2:nrow(rotulos)) {
  rotulos$y_rot[i] <- max(rotulos$share[i], rotulos$y_rot[i - 1] + 0.022)
}

g2 <- ggplot(dados_g2, aes(x = year, y = share, color = pais)) +
  geom_line(linewidth = 1.2) +
  geom_text(
    data = rotulos,
    aes(y = y_rot, label = pais),
    hjust = -0.1, size = 3.6, fontface = "bold"
  ) +
  scale_color_manual(values = cores) +
  scale_x_continuous(breaks = seq(2000, 2025, 5),
                     expand = expansion(mult = c(0.02, 0.3))) +   # espaço p/ rótulos
  scale_y_continuous(labels = pct, limits = c(0, NA),
                     expand = expansion(mult = c(0, 0.05))) +
  labs(
    title    = "Para quem o Brasil vende?",
    subtitle = "Participação dos 5 maiores destinos de 2025 nas exportações, 2000–2025",
    x = NULL, y = "Participação nas exportações", caption = fonte
  ) +
  tema_portfolio()

ggsave("graficos/02_principais_destinos.png", g2,
       width = 9, height = 5.5, dpi = 200)

# ---------- 5. Gráfico 3: concentração (HHI) ----------
extremos <- hhi |> filter(hhi == min(hhi) | hhi == max(hhi))

g3 <- ggplot(hhi, aes(x = year, y = hhi)) +
  geom_area(fill = "#2E4057", alpha = 0.10) +
  geom_line(linewidth = 1.3, color = "#2E4057") +
  geom_point(data = extremos, size = 3.5, color = "#2E4057") +
  geom_text(
    data = extremos,
    aes(label = format(hhi, big.mark = ".", decimal.mark = ",")),
    vjust = -1.2, size = 3.8, fontface = "bold", color = "#2E4057"
  ) +
  scale_x_continuous(breaks = seq(2000, 2025, 5)) +
  scale_y_continuous(labels = label_number(big.mark = ".", decimal.mark = ","),
                     limits = c(0, 1450), expand = expansion(mult = c(0, 0))) +
  labs(
    title    = "Concentração das exportações brasileiras por destino",
    subtitle = "HHI calculado sobre todos os países de destino, 2000–2025\n(quanto maior, mais concentradas as vendas em poucos países)",
    x = NULL, y = "HHI (0 a 10.000)", caption = fonte
  ) +
  tema_portfolio()

ggsave("graficos/03_hhi_destinos.png", g3,
       width = 9, height = 5.5, dpi = 200)

# ---------- 6. Conferências rápidas ----------
print(top5 |> mutate(share_pct = round(share * 100, 1)) |>
        select(pais, share_pct))
g1; g2; g3
