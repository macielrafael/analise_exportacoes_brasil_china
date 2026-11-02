# O quanto o Brasil depende da China?

Análise da evolução e da concentração das exportações brasileiras por país de destino, entre 2000 e 2025.

## Pergunta
A participação da China nas exportações brasileiras cresceu? O Brasil está mais ou menos concentrado em poucos compradores do que há 25 anos?

## Dados
Comex Stat (Ministério do Desenvolvimento, Indústria, Comércio e Serviços), obtidos pela API oficial com o pacote `comexr` do R. Valores em US$ FOB, agregados por país de destino e por ano.

## Principais resultados
- A participação da China subiu de 2% (2000) para 28,7% (2025), com pico de 32,4% em 2020.
- A China ultrapassou os EUA como principal destino por volta de 2009.
- O índice de concentração Herfindahl-Hirschman (HHI) por destino caiu até 2008 (470) e depois mais que dobrou, chegando a 1.239 em 2020. Em 2025, é de 1.041.

![Participação da China](graficos/01_participacao_china.png)
![Principais destinos](graficos/02_principais_destinos.png)
![Concentração (HHI)](graficos/03_hhi_destinos.png)

## Como interpretar o HHI
O HHI é a soma dos quadrados das participações de cada país, multiplicada por 10.000. Quanto maior, mais concentradas as exportações. Mesmo com a alta recente, o nível ainda é baixo em termos absolutos; o ponto relevante é a tendência.

## Limitações
- Os dados mostram o destino declarado, não o destino final (por exemplo, parte do que vai para os Países Baixos segue para outros países europeus).
- A análise é feita pelo valor total, sem separar por produto.

## Como reproduzir
1. Abra o projeto `exportacoes_brasil_china.Rproj` no RStudio.
2. Rode `scripts/01_baixar_dados.R` (coleta pela API; leva alguns minutos).
3. Rode `scripts/02_analise.R` (cálculos e gráficos).

Pacotes utilizados: `comexr`, `dplyr`, `ggplot2`, `scales`.