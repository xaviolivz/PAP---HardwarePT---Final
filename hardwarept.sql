-- phpMyAdmin SQL Dump
-- version 5.2.2
-- https://www.phpmyadmin.net/
--
-- Host: localhost
-- Tempo de geração: 13-Jun-2026 às 10:42
-- Versão do servidor: 8.0.43
-- versão do PHP: 8.2.29

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de dados: `hardwarept`
--

-- --------------------------------------------------------

--
-- Estrutura da tabela `carrinho`
--

CREATE TABLE `carrinho` (
  `id` int NOT NULL,
  `utilizador_id` int DEFAULT NULL,
  `produto_id` int NOT NULL,
  `quantidade` int NOT NULL DEFAULT '1',
  `data_adicao` timestamp NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Estrutura da tabela `categorias`
--

CREATE TABLE `categorias` (
  `id` int NOT NULL,
  `nome` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `slug` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `descricao` text COLLATE utf8mb4_unicode_ci,
  `icone` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `ativo` tinyint(1) DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Extraindo dados da tabela `categorias`
--

INSERT INTO `categorias` (`id`, `nome`, `slug`, `descricao`, `icone`, `ativo`) VALUES
(1, 'Processadores', 'processadores', 'Processadores Intel e AMD para desktop e portáteis', '🖥️', 1),
(2, 'Placas Gráficas', 'placas-graficas', 'Placas gráficas NVIDIA e AMD para gaming e trabalho', '🎮', 1),
(3, 'Memória RAM', 'memoria-ram', 'Módulos de memória DDR4 e DDR5', '💾', 1),
(4, 'Armazenamento', 'armazenamento', 'Discos SSD, HDD e NVMe', '📀', 1),
(5, 'Motherboards', 'motherboards', 'Placas-mãe para Intel e AMD', '🔧', 1),
(6, 'Fontes de Alimentação', 'fontes-de-alimentacao', 'Fontes de alimentação certificadas', '⚡', 1),
(7, 'Caixas PC', 'caixas-pc', 'Caixas para computador de vários tamanhos', '🖥️', 1),
(8, 'Refrigeração', 'refrigeracao', 'Coolers e sistemas de refrigeração', '❄️', 1),
(9, 'Acessórios', 'acessorios', 'Acessórios', NULL, 1);

-- --------------------------------------------------------

--
-- Estrutura da tabela `contactos`
--

CREATE TABLE `contactos` (
  `id` int NOT NULL,
  `nome` varchar(100) NOT NULL,
  `email` varchar(100) NOT NULL,
  `telefone` varchar(20) DEFAULT NULL,
  `assunto` varchar(255) DEFAULT NULL,
  `mensagem` text NOT NULL,
  `estado` enum('novo','lido','respondido','fechado') DEFAULT 'novo',
  `data_criacao` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `data_resposta` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Estrutura da tabela `itens_pedido`
--

CREATE TABLE `itens_pedido` (
  `id` int NOT NULL,
  `pedido_id` int NOT NULL,
  `produto_id` int NOT NULL,
  `quantidade` int NOT NULL,
  `preco_unitario` decimal(10,2) NOT NULL,
  `subtotal` decimal(10,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Estrutura da tabela `pedidos`
--

CREATE TABLE `pedidos` (
  `id` int NOT NULL,
  `utilizador_id` int NOT NULL,
  `numero_pedido` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `total` decimal(10,2) NOT NULL,
  `subtotal` decimal(10,2) DEFAULT NULL,
  `iva` decimal(10,2) DEFAULT NULL,
  `estado` enum('pendente','processando','enviado','entregue','cancelado') COLLATE utf8mb4_unicode_ci DEFAULT 'pendente',
  `metodo_pagamento` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `nome_envio` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `email_envio` varchar(150) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `telefone_envio` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `nif_envio` varchar(9) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `morada_envio` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `cidade_envio` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `codigo_postal_envio` varchar(10) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `data_criacao` timestamp NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Estrutura da tabela `produtos`
--

CREATE TABLE `produtos` (
  `id` int NOT NULL,
  `categoria_id` int NOT NULL,
  `nome` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL,
  `slug` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL,
  `especificacoes` text COLLATE utf8mb4_unicode_ci,
  `preco` decimal(10,2) NOT NULL,
  `preco_promocional` decimal(10,2) DEFAULT NULL,
  `stock` int DEFAULT '0',
  `imagem` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `destaque` tinyint(1) DEFAULT '0',
  `ativo` tinyint(1) DEFAULT '1',
  `data_criacao` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `especificacoes_tecnicas` json DEFAULT NULL,
  `caracteristicas` json DEFAULT NULL,
  `em_promocao` tinyint(1) DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Extraindo dados da tabela `produtos`
--

INSERT INTO `produtos` (`id`, `categoria_id`, `nome`, `slug`, `especificacoes`, `preco`, `preco_promocional`, `stock`, `imagem`, `destaque`, `ativo`, `data_criacao`, `especificacoes_tecnicas`, `caracteristicas`, `em_promocao`) VALUES
(1, 1, 'Intel Core i9-14900K', 'intel-core-i9-14900k', '24 Cores (8P+16E) | 32 Threads | 5.8GHz Turbo | LGA1700 | 125W TDP', 589.99, NULL, 15, 'imagens/i914900k.jpg', 1, 1, '2026-01-06 11:45:35', '{\"TDP\": \"125W\", \"Cache\": \"36 MB Intel Smart Cache\", \"Marca\": \"Intel\", \"Modelo\": \"Core i9-14900K\", \"Socket\": \"LGA 1700\", \"Threads\": \"32\", \"Núcleos\": \"24 (8P + 16E)\", \"Litografia\": \"10nm\", \"Arquitetura\": \"Raptor Lake Refresh\", \"PCI Express\": \"PCIe 5.0 x16, PCIe 4.0\", \"TDP Máximo\": \"253W\", \"Canais Memória\": \"Dual Channel\", \"Suporte Memória\": \"DDR5-5600, DDR4-3200\", \"Frequência Turbo\": \"6.0 GHz\", \"Gráficos Integrados\": \"Intel UHD Graphics 770\", \"Frequência Base P-Core\": \"3.2 GHz\"}', '[\"Processador desbloqueado para overclocking\", \"Tecnologia Intel Turbo Boost Max 3.0\", \"Intel Thread Director para gestão inteligente\", \"24 núcleos híbridos (Performance + Efficiency)\", \"Suporte para DDR5 e DDR4\", \"PCIe 5.0 para máxima velocidade\", \"Ideal para gaming e criação de conteúdo\", \"Intel Deep Learning Boost\", \"Compatível com chipsets Z790 e Z690\", \"Tecnologia Intel Adaptive Boost\"]', 0),
(2, 1, 'Intel Core i7-14700K', 'intel-core-i7-14700k', '20 Cores (8P+12E) | 28 Threads | 5.6GHz Turbo | LGA1700 | 125W TDP', 419.99, NULL, 25, 'imagens/i714700k.jpeg', 1, 1, '2026-01-06 11:45:35', '{\"TDP\": \"125W\", \"Cache\": \"33 MB Intel Smart Cache\", \"Marca\": \"Intel\", \"Modelo\": \"Core i7-14700K\", \"Socket\": \"LGA 1700\", \"Threads\": \"28\", \"Núcleos\": \"20 (8P + 12E)\", \"Litografia\": \"10nm\", \"Arquitetura\": \"Raptor Lake Refresh\", \"PCI Express\": \"PCIe 5.0 x16, PCIe 4.0\", \"TDP Máximo\": \"253W\", \"Canais Memória\": \"Dual Channel\", \"Suporte Memória\": \"DDR5-5600, DDR4-3200\", \"Frequência Turbo\": \"5.6 GHz\", \"Gráficos Integrados\": \"Intel UHD Graphics 770\", \"Frequência Base P-Core\": \"3.4 GHz\"}', '[\"Excelente equilíbrio entre preço e desempenho\", \"Processador desbloqueado (K-series)\", \"Tecnologia Intel Turbo Boost 2.0\", \"20 núcleos para multitarefa eficiente\", \"Suporte nativo para DDR5\", \"Ótimo para gaming a 1440p e 4K\", \"Menor consumo que o i9\", \"Compatível com refrigeração a ar de qualidade\", \"Intel Thread Director\", \"Suporte para até 192GB de RAM\"]', 0),
(3, 1, 'Intel Core i5-14600K', 'intel-core-i5-14600k', '14 Cores (6P+8E) | 20 Threads | 5.3GHz Turbo | LGA1700 | 125W TDP', 319.99, NULL, 24, 'imagens/i514600k.jpeg', 1, 1, '2026-01-06 11:45:35', '{\"TDP\": \"125W\", \"Cache\": \"24 MB Intel Smart Cache\", \"Marca\": \"Intel\", \"Modelo\": \"Core i5-14600K\", \"Socket\": \"LGA 1700\", \"Threads\": \"20\", \"Núcleos\": \"14 (6P + 8E)\", \"Litografia\": \"10nm\", \"Arquitetura\": \"Raptor Lake Refresh\", \"PCI Express\": \"PCIe 5.0 x16, PCIe 4.0\", \"TDP Máximo\": \"181W\", \"Canais Memória\": \"Dual Channel\", \"Suporte Memória\": \"DDR5-5600, DDR4-3200\", \"Frequência Turbo\": \"5.3 GHz\", \"Gráficos Integrados\": \"Intel UHD Graphics 770\", \"Frequência Base P-Core\": \"3.5 GHz\"}', '[\"Melhor custo-benefício para gaming\", \"Processador desbloqueado\", \"14 núcleos para produtividade\", \"Excelente desempenho em single-thread\", \"Baixo consumo energético\", \"Ideal para builds mid-range\", \"Suporte para overclocking\", \"Compatível com refrigeração stock de qualidade\", \"Ótimo para streaming e gaming simultâneo\", \"PCIe 5.0 para futuras GPUs\"]', 0),
(4, 1, 'AMD Ryzen 9 7950X', 'amd-ryzen-9-7950x', '16 Cores | 32 Threads | 5.7GHz Turbo | AM5 | 170W TDP', 549.99, NULL, 12, 'imagens/ryzen97950x.webp', 1, 1, '2026-01-06 11:45:35', '{\"TDP\": \"170W\", \"Marca\": \"AMD\", \"Modelo\": \"Ryzen 9 7950X\", \"Socket\": \"AM5\", \"Threads\": \"32\", \"Cache L2\": \"16 MB\", \"Cache L3\": \"64 MB\", \"Núcleos\": \"16\", \"Litografia\": \"5nm\", \"Arquitetura\": \"Zen 4\", \"PCI Express\": \"PCIe 5.0\", \"Canais Memória\": \"Dual Channel\", \"Frequência Base\": \"4.5 GHz\", \"Suporte Memória\": \"DDR5-5200\", \"Frequência Boost\": \"5.7 GHz\", \"Gráficos Integrados\": \"AMD Radeon Graphics\"}', '[\"Processador topo de gama da AMD\", \"16 núcleos Zen 4 de alta performance\", \"Frequência boost até 5.7 GHz\", \"Arquitetura 5nm para maior eficiência\", \"Suporte nativo DDR5\", \"PCIe 5.0 para máxima velocidade\", \"Ideal para workstations e gaming extremo\", \"Tecnologia AMD Precision Boost\", \"Baixas temperaturas com refrigeração adequada\", \"Excelente para renderização e edição de vídeo\"]', 0),
(5, 1, 'AMD Ryzen 7 7800X3D', 'amd-ryzen-7-7800x3d', '8 Cores | 16 Threads | 5.0GHz Turbo | AM5 | 96MB L3 Cache', 449.99, NULL, 20, 'imagens/ryzen77800x3d.jpg', 1, 1, '2026-01-06 11:45:35', '{\"TDP\": \"120W\", \"Marca\": \"AMD\", \"Modelo\": \"Ryzen 7 7800X3D\", \"Socket\": \"AM5\", \"Threads\": \"16\", \"Cache L2\": \"8 MB\", \"Cache L3\": \"96 MB (3D V-Cache)\", \"Núcleos\": \"8\", \"Litografia\": \"5nm\", \"Arquitetura\": \"Zen 4\", \"PCI Express\": \"PCIe 5.0\", \"Canais Memória\": \"Dual Channel\", \"Frequência Base\": \"4.2 GHz\", \"Suporte Memória\": \"DDR5-5200\", \"Frequência Boost\": \"5.0 GHz\", \"Gráficos Integrados\": \"AMD Radeon Graphics\"}', '[\"Melhor processador para gaming em 2024\", \"Tecnologia AMD 3D V-Cache exclusiva\", \"96MB de cache L3 para máxima performance\", \"Baixo consumo de apenas 120W\", \"Temperaturas mais baixas que outros Ryzen\", \"Não necessita de refrigeração extrema\", \"Ideal para gaming a 1080p, 1440p e 4K\", \"Excelente eficiência energética\", \"Compatível com motherboards AM5\", \"Melhor que i9-14900K em muitos jogos\"]', 0),
(6, 1, 'AMD Ryzen 5 7600X', 'amd-ryzen-5-7600x', '6 Cores | 12 Threads | 5.3GHz Turbo | AM5 | 105W TDP', 249.99, NULL, 35, 'imagens/ryzen57600x.jpg', 1, 1, '2026-01-06 11:45:35', '{\"TDP\": \"105W\", \"Marca\": \"AMD\", \"Modelo\": \"Ryzen 5 7600X\", \"Socket\": \"AM5\", \"Threads\": \"12\", \"Cache L2\": \"6 MB\", \"Cache L3\": \"32 MB\", \"Núcleos\": \"6\", \"Litografia\": \"5nm\", \"Arquitetura\": \"Zen 4\", \"PCI Express\": \"PCIe 5.0\", \"Canais Memória\": \"Dual Channel\", \"Frequência Base\": \"4.7 GHz\", \"Suporte Memória\": \"DDR5-5200\", \"Frequência Boost\": \"5.3 GHz\", \"Gráficos Integrados\": \"AMD Radeon Graphics\"}', '[\"Excelente custo-benefício\", \"6 núcleos Zen 4 poderosos\", \"Frequências muito altas (até 5.3 GHz)\", \"Ideal para gaming 1080p e 1440p\", \"Baixo consumo de energia\", \"Suporte para DDR5\", \"PCIe 5.0 para futuras upgrades\", \"Ótimo para builds entry-level AM5\", \"Desempenho competitivo com i5-14600K\", \"Plataforma com suporte até 2027+\"]', 0),
(7, 2, 'NVIDIA GeForce RTX 4090', 'nvidia-rtx-4090', '24GB GDDR6X | 16384 CUDA Cores | 450W TDP | DLSS 3', 1899.99, 1799.99, 4, 'imagens/rtx4090.webp', 1, 1, '2026-01-06 11:45:35', '{\"TDP\": \"450W\", \"Marca\": \"NVIDIA\", \"Modelo\": \"GeForce RTX 4090\", \"Saídas\": \"3x DisplayPort 1.4a, 1x HDMI 2.1\", \"Memória\": \"24GB GDDR6X\", \"Processo\": \"4nm TSMC\", \"RT Cores\": \"128 (3ª Geração)\", \"CUDA Cores\": \"16384\", \"Clock Base\": \"2230 MHz\", \"Conectores\": \"1x 16-pin PCIe\", \"Arquitetura\": \"Ada Lovelace\", \"Clock Boost\": \"2520 MHz\", \"Tensor Cores\": \"512 (4ª Geração)\", \"Largura Banda\": \"1008 GB/s\", \"Interface Memória\": \"384-bit\"}', '[\"Placa gráfica mais poderosa do mercado\", \"Ray Tracing de 3ª geração\", \"DLSS 3.5 com Frame Generation\", \"24GB VRAM para aplicações profissionais\", \"Perfeita para gaming 4K a 144+ FPS\", \"8K gaming possível\", \"Excelente para criação de conteúdo\", \"Renderização em tempo real\", \"Suporte para até 4 monitores\", \"Tecnologia AV1 encode/decode\", \"Requer fonte de 850W mínimo\", \"NVIDIA Studio para criadores\"]', 1),
(8, 2, 'NVIDIA GeForce RTX 4080 SUPER', 'nvidia-rtx-4080-super', '16GB GDDR6X | 10240 CUDA Cores | 320W TDP | DLSS 3', 1099.99, NULL, 10, 'imagens/4080super.avif', 1, 1, '2026-01-06 11:45:35', '{\"TDP\": \"320W\", \"Marca\": \"NVIDIA\", \"Modelo\": \"GeForce RTX 4080 SUPER\", \"Saídas\": \"3x DisplayPort 1.4a, 1x HDMI 2.1\", \"Memória\": \"16GB GDDR6X\", \"Processo\": \"4nm TSMC\", \"RT Cores\": \"80 (3ª Geração)\", \"CUDA Cores\": \"10240\", \"Clock Base\": \"2295 MHz\", \"Conectores\": \"1x 16-pin PCIe\", \"Arquitetura\": \"Ada Lovelace\", \"Clock Boost\": \"2550 MHz\", \"Tensor Cores\": \"320 (4ª Geração)\", \"Largura Banda\": \"736 GB/s\", \"Interface Memória\": \"256-bit\"}', '[\"Melhor equilíbrio preço/performance no high-end\", \"DLSS 3 com Frame Generation\", \"Ray Tracing de 3ª geração\", \"16GB VRAM suficiente para tudo\", \"Excelente para gaming 4K\", \"1440p a 240+ FPS\", \"Mais eficiente que RTX 4080 original\", \"Overclock facilitado\", \"Menor consumo que RTX 4090\", \"Fonte de 750W recomendada\", \"Design compacto comparado ao 4090\", \"Suporte NVIDIA Reflex\"]', 0),
(9, 2, 'NVIDIA GeForce RTX 4070 Ti SUPER', 'nvidia-rtx-4070-ti-super', '16GB GDDR6X | 8448 CUDA Cores | 285W TDP | DLSS 3', 849.99, 799.99, 15, 'imagens/4070tisuper.webp', 1, 1, '2026-01-06 11:45:35', '{\"TDP\": \"285W\", \"Marca\": \"NVIDIA\", \"Modelo\": \"GeForce RTX 4070 Ti SUPER\", \"Saídas\": \"3x DisplayPort 1.4a, 1x HDMI 2.1\", \"Memória\": \"16GB GDDR6X\", \"Processo\": \"4nm TSMC\", \"RT Cores\": \"66 (3ª Geração)\", \"CUDA Cores\": \"8448\", \"Clock Base\": \"2340 MHz\", \"Conectores\": \"1x 16-pin PCIe\", \"Arquitetura\": \"Ada Lovelace\", \"Clock Boost\": \"2610 MHz\", \"Tensor Cores\": \"264 (4ª Geração)\", \"Largura Banda\": \"672 GB/s\", \"Interface Memória\": \"256-bit\"}', '[\"Excelente para gaming 4K\", \"DLSS 3 com Frame Generation\", \"16GB VRAM em vez de 12GB\", \"Ray Tracing poderoso\", \"Ideal para 1440p ultra settings\", \"Menor consumo que modelos superiores\", \"Overclock fácil e eficiente\", \"Fonte de 700W suficiente\", \"Melhor que RTX 4070 Ti original\", \"Ótima para criadores de conteúdo\", \"Suporte para múltiplos monitores\"]', 1),
(10, 2, 'NVIDIA GeForce RTX 4070 SUPER', 'nvidia-rtx-4070-super', '12GB GDDR6X | 7168 CUDA Cores | 220W TDP | DLSS 3', 629.99, NULL, 20, 'imagens/rtx4070super.webp', 0, 1, '2026-01-06 11:45:35', '{\"TDP\": \"220W\", \"Marca\": \"NVIDIA\", \"Modelo\": \"GeForce RTX 4070 SUPER\", \"Saídas\": \"3x DisplayPort 1.4a, 1x HDMI 2.1\", \"Memória\": \"12GB GDDR6X\", \"Processo\": \"4nm TSMC\", \"RT Cores\": \"56 (3ª Geração)\", \"CUDA Cores\": \"7168\", \"Clock Base\": \"1980 MHz\", \"Conectores\": \"1x 16-pin PCIe\", \"Arquitetura\": \"Ada Lovelace\", \"Clock Boost\": \"2475 MHz\", \"Tensor Cores\": \"224 (4ª Geração)\", \"Largura Banda\": \"504 GB/s\", \"Interface Memória\": \"192-bit\"}', '[\"Melhor custo-benefício da linha 40\", \"Perfeita para 1440p gaming\", \"DLSS 3 com Frame Generation\", \"Ray Tracing eficiente\", \"12GB VRAM para jogos atuais\", \"Baixo consumo de 220W\", \"Fonte de 650W suficiente\", \"Excelente para VR gaming\", \"Overclock estável\", \"Design compacto (2 slots)\", \"Silenciosa em operação\"]', 0),
(11, 2, 'AMD Radeon RX 7900 XTX', 'amd-rx-7900-xtx', '24GB GDDR6 | 6144 Stream Processors | 355W TDP', 999.99, 949.99, 8, 'imagens/amdradeon7900.webp', 1, 1, '2026-01-06 11:45:35', '{\"TDP\": \"355W\", \"Marca\": \"AMD\", \"Modelo\": \"Radeon RX 7900 XTX\", \"Saídas\": \"2x DisplayPort 2.1, 1x HDMI 2.1\", \"Memória\": \"24GB GDDR6\", \"Processo\": \"5nm + 6nm\", \"Conectores\": \"2x 8-pin\", \"Game Clock\": \"2300 MHz\", \"Arquitetura\": \"RDNA 3\", \"Boost Clock\": \"2500 MHz\", \"Largura Banda\": \"960 GB/s\", \"Ray Accelerators\": \"96\", \"Stream Processors\": \"6144\", \"Interface Memória\": \"384-bit\"}', '[\"Topo de gama da AMD\", \"Arquitetura RDNA 3 avançada\", \"24GB de VRAM para criadores\", \"Excelente para gaming 4K\", \"Ray Tracing de 2ª geração\", \"FSR 3 com Frame Generation\", \"Melhor preço que RTX 4080\", \"DisplayPort 2.1 UHBR13.5\", \"Ideal para resoluções ultra-wide\", \"Overclock robusto\", \"Fonte de 800W recomendada\"]', 1),
(12, 2, 'AMD Radeon RX 7800 XT', 'amd-rx-7800-xt', '16GB GDDR6 | 3840 Stream Processors | 263W TDP', 549.99, NULL, 18, 'imagens/amdradeon.jpg', 0, 1, '2026-01-06 11:45:35', '{\"TDP\": \"263W\", \"Marca\": \"AMD\", \"Modelo\": \"Radeon RX 7800 XT\", \"Saídas\": \"2x DisplayPort 2.1, 1x HDMI 2.1\", \"Memória\": \"16GB GDDR6\", \"Processo\": \"5nm + 6nm\", \"Conectores\": \"2x 8-pin\", \"Game Clock\": \"2124 MHz\", \"Arquitetura\": \"RDNA 3\", \"Boost Clock\": \"2430 MHz\", \"Largura Banda\": \"624 GB/s\", \"Ray Accelerators\": \"60\", \"Stream Processors\": \"3840\", \"Interface Memória\": \"256-bit\"}', '[\"Excelente para 1440p gaming\", \"Melhor custo-benefício AMD\", \"16GB VRAM para jogos futuros\", \"FSR 3 com Frame Generation\", \"Ray Tracing competente\", \"Consumo moderado de 263W\", \"Fonte de 700W suficiente\", \"Overclock estável\", \"Ideal para competitivo\", \"Alternativa ao RTX 4070\", \"DisplayPort 2.1\"]', 0),
(13, 3, 'Corsair Dominator Platinum RGB 32GB DDR5', 'corsair-dominator-32gb-ddr5', '2x16GB | DDR5-6000 | CL36 | RGB | Intel XMP 3.0', 189.99, 100.00, 25, 'imagens/dominator.avif', 1, 1, '2026-01-06 11:45:35', '{\"RGB\": \"Sim - 12 LEDs por módulo\", \"Tipo\": \"DDR5\", \"Marca\": \"Corsair\", \"Modelo\": \"Dominator Platinum RGB\", \"Perfil\": \"Intel XMP 3.0, AMD EXPO\", \"Timings\": \"30-36-36-76\", \"Garantia\": \"Vitalícia\", \"Voltagem\": \"1.35V\", \"Capacidade\": \"32GB (2x16GB)\", \"Dissipador\": \"Alumínio premium\", \"Frequência\": \"6000 MHz\", \"Latência CAS\": \"CL30\"}', '[\"Memória topo de gama Corsair\", \"Design premium em alumínio\", \"RGB Capellix brilhante\", \"XMP 3.0 e AMD EXPO\", \"Frequência alta de 6000MHz\", \"Latências otimizadas CL30\", \"Excelente para overclocking\", \"Compatível Intel 12ª gen+\", \"Compatível AMD Ryzen 7000\", \"Software iCUE para controlo RGB\", \"Garantia vitalícia Corsair\"]', 1),
(14, 3, 'G.Skill Trident Z5 RGB 32GB DDR5', 'gskill-trident-z5-32gb-ddr5', '2x16GB | DDR5-6400 | CL32 | RGB | AMD EXPO', 199.99, NULL, 20, 'imagens/tridentddr5.webp', 1, 1, '2026-01-06 11:45:35', '{\"RGB\": \"Sim - Trident Z5 RGB\", \"Tipo\": \"DDR5\", \"Marca\": \"G.Skill\", \"Modelo\": \"Trident Z5 RGB\", \"Perfil\": \"Intel XMP 3.0\", \"Timings\": \"32-39-39-102\", \"Garantia\": \"Vitalícia\", \"Voltagem\": \"1.40V\", \"Capacidade\": \"32GB (2x16GB)\", \"Dissipador\": \"Alumínio escovado\", \"Frequência\": \"6400 MHz\", \"Latência CAS\": \"CL32\"}', '[\"Frequências extremas de 6400MHz\", \"Design icónico Trident Z5\", \"RGB vibrante e personalizável\", \"Timings CL32 otimizados\", \"Ideal para Intel 13ª/14ª gen\", \"ICs Samsung B-Die selecionados\", \"Excelente para overclocking extremo\", \"Compatível com Asus Aura Sync\", \"Testado 100% a 6400MHz\", \"Perfil XMP 3.0 pré-configurado\", \"Garantia vitalícia G.Skill\"]', 0),
(15, 3, 'Kingston Fury Beast 32GB DDR5', 'kingston-fury-beast-32gb-ddr5', '2x16GB | DDR5-5600 | CL40 | Heat Spreader', 129.99, 119.99, 40, 'imagens/FURYDDR5.JPG', 0, 1, '2026-01-06 11:45:35', '{\"RGB\": \"Não\", \"Tipo\": \"DDR5\", \"Marca\": \"Kingston\", \"Modelo\": \"Fury Beast\", \"Perfil\": \"Intel XMP 3.0, AMD EXPO\", \"Timings\": \"36-38-38-80\", \"Garantia\": \"Vitalícia\", \"Voltagem\": \"1.25V\", \"Capacidade\": \"32GB (2x16GB)\", \"Dissipador\": \"Alumínio low-profile\", \"Frequência\": \"5600 MHz\", \"Latência CAS\": \"CL36\"}', '[\"Melhor custo-benefício DDR5\", \"Design low-profile compacto\", \"Compatível com coolers grandes\", \"5600MHz - velocidade padrão DDR5\", \"XMP 3.0 e AMD EXPO\", \"Baixa voltagem de 1.25V\", \"Ideal para builds básicas AM5/LGA1700\", \"Sem RGB para quem não precisa\", \"Excelente estabilidade\", \"Marca confiável Kingston\", \"Garantia vitalícia\"]', 1),
(16, 3, 'Corsair Vengeance RGB 32GB DDR4', 'corsair-vengeance-32gb-ddr4', '2x16GB | DDR4-3600 | CL18 | RGB', 89.99, NULL, 50, 'imagens/vengeance32gb.avif', 0, 1, '2026-01-06 11:45:35', '{\"RGB\": \"Sim - 10 LEDs por módulo\", \"Tipo\": \"DDR4\", \"Marca\": \"Corsair\", \"Modelo\": \"Vengeance RGB\", \"Perfil\": \"Intel XMP 2.0\", \"Timings\": \"18-22-22-42\", \"Garantia\": \"Vitalícia\", \"Voltagem\": \"1.35V\", \"Capacidade\": \"32GB (2x16GB)\", \"Dissipador\": \"Alumínio\", \"Frequência\": \"3600 MHz\", \"Latência CAS\": \"CL18\"}', '[\"Sweet spot DDR4 - 3600MHz CL18\", \"RGB vibrante personalizável\", \"Excelente para Ryzen 5000\", \"Compatível Intel 10ª-14ª gen\", \"Perfil XMP 2.0 fácil\", \"Overclock estável\", \"Software iCUE para RGB\", \"Design testado e comprovado\", \"32GB para multitarefa\", \"Corsair - marca confiável\", \"Garantia vitalícia\"]', 0),
(17, 3, 'G.Skill Trident Z Neo 64GB DDR4', 'gskill-trident-z-neo-64gb-ddr4', '2x32GB | DDR4-3600 | CL16 | RGB | AMD Optimized', 169.99, 149.99, 15, 'imagens/tridentddr4.avif', 0, 1, '2026-01-06 11:45:35', '{\"RGB\": \"Sim - Trident Z RGB\", \"Tipo\": \"DDR4\", \"Marca\": \"G.Skill\", \"Modelo\": \"Trident Z Neo\", \"Perfil\": \"Intel XMP 2.0\", \"Timings\": \"16-19-19-39\", \"Garantia\": \"Vitalícia\", \"Voltagem\": \"1.35V\", \"Capacidade\": \"64GB (2x32GB)\", \"Dissipador\": \"Alumínio premium\", \"Frequência\": \"3600 MHz\", \"Latência CAS\": \"CL16\"}', '[\"Kit de 64GB para workstations\", \"Timings apertados CL16\", \"Otimizado para AMD Ryzen\", \"Design Trident Z Neo\", \"RGB sincronizável\", \"ICs Samsung B-Die premium\", \"Excelente para edição de vídeo\", \"Renderização 3D\", \"Máquinas virtuais\", \"Gaming + streaming pesado\", \"Garantia vitalícia G.Skill\"]', 1),
(18, 4, 'Samsung 990 PRO 2TB NVMe', 'samsung-990-pro-2tb', '2TB | PCIe 4.0 x4 | 7450MB/s Leitura | 6900MB/s Escrita', 189.99, 169.99, 30, 'imagens/ssdsamsung2tb.avif', 1, 1, '2026-01-06 11:45:35', '{\"TBW\": \"1200 TB\", \"DRAM\": \"Sim - 2GB LPDDR4\", \"NAND\": \"V-NAND TLC 3-bit\", \"Marca\": \"Samsung\", \"Modelo\": \"990 PRO\", \"Garantia\": \"5 anos\", \"Interface\": \"PCIe 4.0 x4, NVMe 2.0\", \"Capacidade\": \"2TB\", \"Controlador\": \"Samsung Elpis\", \"Form Factor\": \"M.2 2280\", \"IOPS Escrita\": \"1550K\", \"IOPS Leitura\": \"1400K\", \"Escrita Sequencial\": \"6900 MB/s\", \"Leitura Sequencial\": \"7450 MB/s\"}', '[\"SSD mais rápido da Samsung\", \"Velocidades PCIe 4.0 máximas\", \"7450 MB/s leitura\", \"Controlador proprietário Samsung\", \"Cache DRAM para consistência\", \"TLC NAND confiável\", \"Dissipador incluído\", \"Software Samsung Magician\", \"Ideal para gaming e criação\", \"Excelente para PS5\", \"5 anos de garantia\"]', 1),
(19, 4, 'WD Black SN850X 2TB', 'wd-black-sn850x-2tb', '2TB | PCIe 4.0 x4 | 7300MB/s Leitura | RGB Heatsink', 179.99, NULL, 25, 'imagens/wdblack2tb.avif', 1, 1, '2026-01-06 11:45:35', '{\"TBW\": \"1200 TB\", \"DRAM\": \"Sim - 2GB DDR4\", \"NAND\": \"BiCS5 TLC\", \"Marca\": \"Western Digital\", \"Modelo\": \"WD Black SN850X\", \"Garantia\": \"5 anos\", \"Interface\": \"PCIe 4.0 x4, NVMe 1.4\", \"Capacidade\": \"2TB\", \"Controlador\": \"WD G2\", \"Form Factor\": \"M.2 2280\", \"IOPS Escrita\": \"1100K\", \"IOPS Leitura\": \"1200K\", \"Escrita Sequencial\": \"6600 MB/s\", \"Leitura Sequencial\": \"7300 MB/s\"}', '[\"Gaming SSD premium\", \"Game Mode 2.0\", \"Velocidades PCIe 4.0 extremas\", \"RGB opcional disponível\", \"Cache DRAM para desempenho\", \"Ideal para DirectStorage\", \"Compatível com PS5\", \"Software WD Dashboard\", \"Baixas latências\", \"Overclock via software\", \"5 anos de garantia WD\"]', 0),
(20, 4, 'Crucial T700 2TB', 'crucial-t700-2tb', '2TB | PCIe 5.0 x4 | 12400MB/s Leitura | 11800MB/s Escrita', 299.99, 279.99, 10, 'imagens/crucial2tb.webp', 1, 1, '2026-01-06 11:45:35', '{\"TBW\": \"1200 TB\", \"DRAM\": \"Sim - 4GB DDR4\", \"NAND\": \"Micron 232-layer TLC\", \"Marca\": \"Crucial\", \"Modelo\": \"T700\", \"Garantia\": \"5 anos\", \"Interface\": \"PCIe 5.0 x4, NVMe 2.0\", \"Capacidade\": \"2TB\", \"Controlador\": \"Phison E26\", \"Form Factor\": \"M.2 2280\", \"IOPS Escrita\": \"1500K\", \"IOPS Leitura\": \"1500K\", \"Escrita Sequencial\": \"11800 MB/s\", \"Leitura Sequencial\": \"12400 MB/s\"}', '[\"SSD PCIe 5.0 mais rápido\", \"Velocidades absurdas de 12400 MB/s\", \"Controlador Phison E26\", \"Micron NAND de 232 camadas\", \"4GB de cache DRAM\", \"Dissipador robusto incluído\", \"Ideal para workstations\", \"Futuro-proof PCIe 5.0\", \"Excelente para transferências massivas\", \"Compatível Z790/X670E\", \"5 anos de garantia\"]', 1),
(21, 4, 'Samsung 870 EVO 1TB SATA', 'samsung-870-evo-1tb', '1TB | SATA III | 560MB/s Leitura | 530MB/s Escrita', 89.99, NULL, 45, 'imagens/ssdsamsung1tb.avif', 0, 1, '2026-01-06 11:45:35', '{\"TBW\": \"600 TB\", \"DRAM\": \"Sim - 1GB LPDDR4\", \"NAND\": \"V-NAND TLC 3-bit\", \"Marca\": \"Samsung\", \"Modelo\": \"870 EVO\", \"Garantia\": \"5 anos\", \"Interface\": \"SATA III 6Gb/s\", \"Capacidade\": \"1TB\", \"Controlador\": \"Samsung MKX\", \"Form Factor\": \"2.5\\\"\", \"IOPS Escrita\": \"88K\", \"IOPS Leitura\": \"98K\", \"Escrita Sequencial\": \"530 MB/s\", \"Leitura Sequencial\": \"560 MB/s\"}', '[\"Melhor SSD SATA do mercado\", \"Velocidades SATA máximas\", \"Confiabilidade Samsung\", \"Cache DRAM para consistência\", \"Ideal para upgrade de laptops\", \"Secundário para PCs\", \"Software Samsung Magician\", \"TBW muito alto\", \"Baixo consumo de energia\", \"Formato 2.5\\\" universal\", \"5 anos de garantia\"]', 0),
(22, 4, 'Seagate Barracuda 4TB HDD', 'seagate-barracuda-4tb', '4TB | 7200RPM | SATA III | 256MB Cache', 89.99, 79.99, 35, 'imagens/barracuda4tb.avif', 0, 1, '2026-01-06 11:45:35', '{\"RPM\": \"5400\", \"MTBF\": \"1 milhão de horas\", \"Cache\": \"256 MB\", \"Marca\": \"Seagate\", \"Modelo\": \"Barracuda\", \"Garantia\": \"2 anos\", \"Interface\": \"SATA III 6Gb/s\", \"Capacidade\": \"4TB\", \"Form Factor\": \"3.5\\\"\", \"Consumo Idle\": \"2.5W\", \"Consumo Ativo\": \"4.1W\", \"Velocidade Transferência\": \"190 MB/s\"}', '[\"HDD para armazenamento em massa\", \"4TB para jogos, vídeos, backups\", \"Silencioso - 5400 RPM\", \"Cache grande de 256MB\", \"Baixo consumo energético\", \"Ideal como drive secundário\", \"Custo por GB imbatível\", \"Confiabilidade Seagate\", \"Perfeito para arquivos grandes\", \"MTBF de 1 milhão de horas\", \"2 anos de garantia\"]', 1),
(23, 5, 'ASUS ROG Maximus Z790 Hero', 'asus-rog-maximus-z790-hero', 'LGA1700 | Z790 | DDR5 | PCIe 5.0 | WiFi 6E | 2.5Gb LAN', 629.99, 599.99, 8, 'imagens/z790.avif', 1, 1, '2026-01-06 11:45:35', '{\"Rede\": \"Intel 2.5G LAN + WiFi 6E\", \"SATA\": \"4x SATA 6Gb/s\", \"Audio\": \"ROG SupremeFX 7.1\", \"Marca\": \"ASUS\", \"Modelo\": \"ROG Maximus Z790 Hero\", \"Socket\": \"LGA 1700\", \"Chipset\": \"Intel Z790\", \"Memória\": \"4x DDR5, até 192GB, 7800MHz+ OC\", \"Fases VRM\": \"20+1 (90A DrMOS)\", \"M.2 Slots\": \"5x M.2 (2x PCIe 5.0)\", \"Slots PCIe\": \"1x PCIe 5.0 x16, 2x PCIe 4.0 x16\", \"Form Factor\": \"ATX\", \"USB Traseira\": \"1x Thunderbolt 4, 1x USB 3.2 Gen 2x2, 8x USB 3.2\"}', '[\"Motherboard topo de gama Z790\", \"VRM robusto 20+1 fases\", \"Suporte DDR5 até 7800MHz+\", \"PCIe 5.0 para GPU e storage\", \"5 slots M.2 - 2 com PCIe 5.0\", \"Thunderbolt 4 integrado\", \"WiFi 6E ultra-rápido\", \"RGB Aura Sync extensivo\", \"BIOS flashback e clear CMOS\", \"Ideal para overclocking extremo\", \"Design premium ROG\", \"Audio SupremeFX de qualidade\"]', 1),
(25, 5, 'ASUS ROG Crosshair X670E Hero', 'asus-rog-crosshair-x670e-hero', 'AM5 | X670E | DDR5 | PCIe 5.0 | WiFi 6E | 2.5Gb LAN', 699.99, 649.99, 6, 'imagens/x670e.png', 1, 1, '2026-01-06 11:45:35', '{\"Rede\": \"Intel 2.5G LAN + WiFi 6E\", \"SATA\": \"4x SATA 6Gb/s\", \"Audio\": \"ROG SupremeFX 7.1\", \"Marca\": \"ASUS\", \"Modelo\": \"ROG Crosshair X670E Hero\", \"Socket\": \"AM5\", \"Chipset\": \"AMD X670E\", \"Memória\": \"4x DDR5, até 128GB, 6400MHz+ OC\", \"Fases VRM\": \"18+2 (110A DrMOS)\", \"M.2 Slots\": \"4x M.2 (2x PCIe 5.0)\", \"Slots PCIe\": \"2x PCIe 5.0 x16\", \"Form Factor\": \"ATX\", \"USB Traseira\": \"2x USB4, 1x USB 3.2 Gen 2x2, 8x USB 3.2\"}', '[\"Topo de gama AM5\", \"Chipset X670E - máxima conectividade\", \"VRM 18+2 fases poderoso\", \"2x PCIe 5.0 x16 completos\", \"DDR5 até 6400MHz+ OC\", \"USB4 integrado (40Gbps)\", \"WiFi 6E ultra-rápido\", \"Design ROG premium\", \"RGB Aura Sync\", \"Ideal para Ryzen 7000/9000\", \"Overclocking avançado\", \"BIOS user-friendly\"]', 1),
(26, 5, 'Gigabyte B650 AORUS Elite AX', 'gigabyte-b650-aorus-elite-ax', 'AM5 | B650 | DDR5 | PCIe 4.0 | WiFi 6E', 229.99, NULL, 20, 'imagens/b650aorus.png', 0, 1, '2026-01-06 11:45:35', '{\"Rede\": \"Realtek 2.5G LAN + WiFi 6E\", \"SATA\": \"4x SATA 6Gb/s\", \"Audio\": \"Realtek ALC1220\", \"Marca\": \"Gigabyte\", \"Modelo\": \"B650 AORUS Elite AX\", \"Socket\": \"AM5\", \"Chipset\": \"AMD B650\", \"Memória\": \"4x DDR5, até 128GB, 6400MHz+ OC\", \"Fases VRM\": \"12+2+2 (60A DrMOS)\", \"M.2 Slots\": \"3x M.2 (1x PCIe 4.0)\", \"Slots PCIe\": \"1x PCIe 4.0 x16, 1x PCIe 3.0 x16\", \"Form Factor\": \"ATX\", \"USB Traseira\": \"1x USB 3.2 Gen 2, 6x USB 3.2\"}', '[\"Melhor custo-benefício AM5\", \"Chipset B650 com ótimas features\", \"VRM 12+2+2 suficiente para Ryzen 9\", \"DDR5 até 6400MHz\", \"WiFi 6E integrado\", \"PCIe 4.0 para GPU\", \"3 slots M.2\", \"RGB Fusion 2.0\", \"Q-Flash Plus\", \"Ideal para builds mid-range\", \"Suporte Ryzen 7000/9000\", \"Excelente qualidade Gigabyte\"]', 0),
(27, 6, 'Corsair RM1000x', 'corsair-rm1000x-1000w', '1000W | 80 Plus Gold | Full Modular | ATX 3.0', 199.99, NULL, 12, 'imagens/corsair1000w.avif', 0, 1, '2026-02-05 16:04:26', '{\"Tipo\": \"ATX 3.0\", \"Marca\": \"Corsair\", \"Modelo\": \"RM1000x\", \"Garantia\": \"10 anos\", \"Potência\": \"1000W\", \"Modulação\": \"Full-Modular\", \"Certificação\": \"80 Plus Gold\"}', '[\"Fonte topo de gama 1000W\", \"Certificação 80 Plus Gold\", \"Full-modular para cable management\", \"10 anos de garantia\"]', 0),
(28, 6, 'Seasonic PRIME TX-850', 'seasonic-prime-tx-850', '850W | 80 Plus Titanium | Full Modular', 249.99, NULL, 8, 'imagens/seasonic850w.jpg', 0, 1, '2026-02-05 16:04:26', '{\"Marca\": \"Seasonic\", \"Modelo\": \"PRIME TX-850\", \"Garantia\": \"12 anos\", \"Potência\": \"850W\", \"Modulação\": \"Full-Modular\", \"Certificação\": \"80 Plus Titanium\"}', '[\"Certificação Titanium (94%+)\", \"Melhor marca em fontes\", \"12 anos de garantia\"]', 0),
(29, 6, 'be quiet! Dark Power 13 1000W', 'be-quiet-dark-power-13', '1000W | 80 Plus Titanium | Silent Wings', 279.99, NULL, 6, 'imagens/bequiet650w.webp', 0, 1, '2026-02-05 16:04:26', '{\"Marca\": \"be quiet!\", \"Modelo\": \"Dark Power 13\", \"Garantia\": \"10 anos\", \"Potência\": \"1000W\", \"Ventoinha\": \"Silent Wings\", \"Certificação\": \"80 Plus Titanium\"}', '[\"Fonte mais silenciosa do mercado\", \"Certificação Titanium\", \"Design stealth preto total\"]', 0),
(30, 7, 'Lian Li O11 Dynamic EVO', 'lian-li-o11-dynamic-evo', 'Mid Tower | ATX/EATX | 3x Vidro Temperado', 169.99, NULL, 10, 'imagens/lianli011.jpg', 1, 1, '2026-02-05 16:04:26', '{\"Tipo\": \"Mid Tower\", \"Marca\": \"Lian Li\", \"Modelo\": \"O11 Dynamic EVO\", \"Form Factor\": \"ATX, EATX\", \"Painéis Vidro\": \"3 painéis\", \"Suporte Radiador\": \"3x 360mm\"}', '[\"Caixa icónica Lian Li\", \"3 painéis de vidro temperado\", \"Suporta 3x radiadores 360mm\", \"Design premium\"]', 0),
(31, 7, 'NZXT H7 Flow', 'nzxt-h7-flow', 'Mid Tower | ATX | Airflow otimizado', 149.99, 119.20, 15, 'imagens/nzxth7.jpg', 0, 1, '2026-02-05 16:04:26', '{\"Tipo\": \"Mid Tower\", \"Marca\": \"NZXT\", \"Modelo\": \"H7 Flow\", \"Painel\": \"Mesh frontal\", \"Ventoinhas\": \"3x 120mm incluídas\"}', '[\"Design minimalista NZXT\", \"Airflow otimizado\", \"3 ventoinhas incluídas\", \"Fácil de construir\"]', 1),
(32, 7, 'Corsair 5000D Airflow', 'corsair-5000d-airflow', 'Mid Tower | ATX/EATX | 2x 120mm AirGuide', 179.99, NULL, 8, 'imagens/corsair4000.jpg', 0, 1, '2026-02-05 16:04:26', '{\"Tipo\": \"Mid Tower\", \"Marca\": \"Corsair\", \"Modelo\": \"5000D Airflow\", \"Suporte\": \"ATX, EATX\", \"Ventoinhas\": \"2x 120mm AirGuide\"}', '[\"Airflow excepcional\", \"Espaçosa e versátil\", \"Cable management premium\"]', 0),
(34, 8, 'Noctua NH-D15 chromax.black', 'noctua-nh-d15-chromax', 'Torre Dupla | 6x Heatpipes | 165mm altura', 119.99, 95.92, 19, 'imagens/noctuanhd15.jpg', 0, 1, '2026-02-05 16:05:21', '{\"TDP\": \"250W+\", \"Tipo\": \"Air Cooler\", \"Marca\": \"Noctua\", \"Altura\": \"165mm\", \"Modelo\": \"NH-D15 chromax.black\", \"Heatpipes\": \"6x 6mm\"}', '[\"Melhor air cooler do mercado\", \"Performance igual a AIOs\", \"Extremamente silencioso\", \"Qualidade Noctua lendária\"]', 1),
(35, 8, 'Corsair iCUE H150i Elite LCD', 'corsair-icue-h150i-elite', '360mm | AIO Liquid | LCD IPS 2.1\" | RGB', 279.99, NULL, 7, 'imagens/corsairh150elite.avif', 1, 1, '2026-02-05 16:05:21', '{\"Tipo\": \"AIO Liquid\", \"Marca\": \"Corsair\", \"Modelo\": \"iCUE H150i Elite LCD\", \"Display\": \"IPS LCD 2.1 polegadas\", \"Tamanho\": \"360mm\", \"Garantia\": \"5 anos\"}', '[\"AIO topo de gama Corsair\", \"LCD IPS alta resolução\", \"RGB sincronizado iCUE\", \"Design premium\"]', 0),
(38, 6, 'EVGA SuperNOVA 750 G6', 'evga-supernova-750-g6', '750W | 80+ Gold | Full Modular | Compact Design', 119.99, 109.99, 25, 'imagens/evga750W.png', 0, 1, '2026-01-23 09:25:40', '{\"Tipo\": \"ATX 3.0\", \"Marca\": \"EVGA\", \"Modelo\": \"SuperNOVA 750 G6\", \"Garantia\": \"10 anos\", \"Potência\": \"750W\", \"Modulação\": \"Full-Modular\", \"Certificação\": \"80 Plus Gold\"}', '[\"ATX 3.0 com PCIe 5.0\", \"Certificação Gold\", \"Full-modular\", \"Ideal para RTX 4070\"]', 1),
(39, 6, 'Corsair HX1500i 1500W', 'corsair-hx1500i-1500w', '1500W | 80+ Platinum | Full Modular | RGB', 399.99, NULL, 8, 'imagens/corsairhvi1500w.jpg', 1, 1, '2026-01-23 09:25:40', '{\"Tipo\": \"ATX 3.0\", \"Marca\": \"Corsair\", \"Modelo\": \"HX1500i\", \"Garantia\": \"10 anos\", \"Potência\": \"1500W\", \"Modulação\": \"Full-Modular\", \"Certificação\": \"80 Plus Platinum\"}', '[\"Potência extrema de 1500W\", \"2x conectores PCIe 5.0\", \"Ideal para dual RTX 4090\", \"Corsair Link monitoring\"]', 0),
(40, 6, 'be quiet! Straight Power 11 650W', 'be-quiet-straight-power-650w', '650W | 80+ Gold | Modular | Silent', 99.99, 89.99, 34, 'imagens/bequiet650w.webp', 0, 1, '2026-01-23 09:25:40', '{\"Marca\": \"be quiet!\", \"Modelo\": \"Straight Power 11\", \"Garantia\": \"5 anos\", \"Potência\": \"650W\", \"Modulação\": \"Full-Modular\", \"Certificação\": \"80 Plus Gold\"}', '[\"Fonte silenciosa be quiet!\", \"Certificação Gold\", \"Silent Wings 3 fan\", \"Ideal para RTX 4060 Ti/4060\"]', 1),
(72, 7, 'NZXT H9 Flow', 'nzxt-h9-flow', 'Mid Tower | ATX | Vidro Temperado | Airflow Otimizado', 189.99, NULL, 9, 'imagens/nzxth9.avif', 1, 1, '2026-02-06 09:33:53', '{\"Tipo\": \"Mid Tower\", \"Marca\": \"NZXT\", \"Modelo\": \"H9 Flow\", \"Painéis\": \"Vidro temperado\", \"Form Factor\": \"ATX, mATX, ITX\", \"Suporte Radiador\": \"Até 420mm\"}', '[\"Excelente gestão de cabos\", \"Painéis em vidro temperado\", \"Ótimo fluxo de ar\", \"Design limpo e moderno\"]', 0),
(73, 7, 'NZXT H5 Elite', 'nzxt-h5-elite', 'Mid Tower | ATX | Vidro Temperado | RGB', 139.99, NULL, 14, 'imagens/h5elite.webp', 0, 1, '2026-02-06 09:33:53', '{\"Tipo\": \"Mid Tower\", \"Marca\": \"NZXT\", \"Modelo\": \"H5 Elite\", \"Painéis\": \"Vidro temperado\", \"Form Factor\": \"ATX, mATX, ITX\", \"Suporte Radiador\": \"Até 360mm\"}', '[\"Iluminação RGB incluída\", \"Design compacto\", \"Boa refrigeração\", \"Vidro temperado frontal\"]', 0),
(74, 7, 'Corsair 4000D Airflow', 'corsair-4000d-airflow', 'Mid Tower | ATX | Airflow | Vidro Temperado', 99.99, NULL, 20, 'imagens/corsair4000.jpg', 0, 1, '2026-02-06 09:33:53', '{\"Tipo\": \"Mid Tower\", \"Marca\": \"Corsair\", \"Modelo\": \"4000D Airflow\", \"Painéis\": \"Vidro temperado + Mesh frontal\", \"Form Factor\": \"ATX, mATX, ITX\", \"Suporte Radiador\": \"Até 360mm frontal\"}', '[\"Painel frontal perfurado\", \"Excelente airflow\", \"Fácil montagem\", \"Ótima gestão de cabos\"]', 0),
(75, 8, 'Arctic Liquid Freezer III 360', 'arctic-liquid-freezer-iii-360', 'Water Cooler | 360mm | Compatível Intel e AMD', 139.99, NULL, 6, 'imagens/arctic-cooler.png', 1, 1, '2026-02-06 09:37:42', '{\"Tipo\": \"Water Cooler AIO\", \"Marca\": \"Arctic\", \"Modelo\": \"Liquid Freezer III 360\", \"Radiador\": \"360mm\", \"Ventoinhas\": \"3x 120mm PWM\", \"Compatibilidade\": \"Intel e AMD\"}', '[\"Radiador de 360mm\", \"Bomba otimizada Arctic\", \"Excelente custo-benefício\", \"Baixo ruído\"]', 0),
(76, 8, 'Arctic Liquid Freezer II 280', 'arctic-liquid-freezer-ii-280', 'Water Cooler | 280mm | Compatível Intel e AMD', 109.99, NULL, 12, 'imagens/arcticii.webp', 0, 1, '2026-02-06 09:37:42', '{\"Tipo\": \"Water Cooler AIO\", \"Marca\": \"Arctic\", \"Modelo\": \"Liquid Freezer II 280\", \"Radiador\": \"280mm\", \"Ventoinhas\": \"2x 140mm PWM\", \"Compatibilidade\": \"Intel e AMD\"}', '[\"Radiador de 280mm\", \"Muito silencioso\", \"Alta eficiência térmica\", \"Excelente reputação\"]', 0),
(77, 8, 'Corsair iCUE H150i Elite', 'corsair-h150i-elite', 'Water Cooler | 360mm | RGB | Intel e AMD', 189.99, NULL, 2, 'imagens/corsairh150elite.avif', 0, 1, '2026-02-06 09:37:42', '{\"Tipo\": \"Water Cooler AIO\", \"Marca\": \"Corsair\", \"Modelo\": \"iCUE H150i Elite\", \"Radiador\": \"360mm\", \"Software\": \"Corsair iCUE\", \"Ventoinhas\": \"3x 120mm RGB\"}', '[\"Iluminação RGB avançada\", \"Compatível com iCUE\", \"Radiador 360mm\", \"Alta performance térmica\"]', 0),
(78, 8, 'NZXT Kraken X63', 'nzxt-kraken-x63', 'Water Cooler | 280mm | RGB | Intel e AMD', 159.99, NULL, 0, 'imagens/krakenx63.avif', 1, 1, '2026-02-06 09:37:42', '{\"Tipo\": \"Water Cooler AIO\", \"Marca\": \"NZXT\", \"Modelo\": \"Kraken X63\", \"Radiador\": \"280mm\", \"Software\": \"NZXT CAM\", \"Ventoinhas\": \"2x 140mm RGB\"}', '[\"Display infinito NZXT\", \"Radiador de 280mm\", \"Design premium\", \"Excelente desempenho\"]', 0),
(80, 9, 'Arctic MX-6 Thermal Paste', 'arctic-mx-6-thermal-paste', 'Alta condutividade térmica | Não condutiva | Longa durabilidade', 9.99, NULL, 43, 'imagens/pastatermicaarctic.jpg', 0, 1, '2026-02-06 09:45:17', '{\"Peso\": \"4g\", \"Tipo\": \"Pasta Térmica\", \"Marca\": \"Arctic\", \"Modelo\": \"MX-6\", \"Garantia\": \"8 anos\", \"Não Condutiva\": \"Sim\", \"Condutividade Térmica\": \"8.5 W/mK\", \"Temperatura de Operação\": \"-40°C a 150°C\"}', '[\"Excelente transferência térmica\", \"Não condutiva eletricamente\", \"Fácil aplicação\", \"Alta durabilidade sem secar\"]', 0);

-- --------------------------------------------------------

--
-- Estrutura da tabela `produto_imagens`
--

CREATE TABLE `produto_imagens` (
  `id` int NOT NULL,
  `produto_id` int NOT NULL,
  `url` varchar(500) COLLATE utf8mb4_unicode_ci NOT NULL,
  `criado_em` timestamp NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Extraindo dados da tabela `produto_imagens`
--

INSERT INTO `produto_imagens` (`id`, `produto_id`, `url`, `criado_em`) VALUES
(3, 75, 'imagens/arcticoolerIII2.jpg', '2026-04-12 14:58:23'),
(5, 80, 'imagens/arcticimg2.jpg', '2026-05-18 19:26:10'),
(6, 80, 'imagens/arcticimg3.jpg', '2026-05-18 19:26:50'),
(7, 78, 'imagens/nzxtx63img1.webp', '2026-05-18 19:29:09'),
(8, 78, 'imagens/nzxtx63img2.webp', '2026-05-18 19:30:06'),
(9, 77, 'imagens/corsairicue.jpg', '2026-05-18 21:55:47'),
(10, 76, 'imagens/arctic280img2.webp', '2026-05-18 21:57:39'),
(11, 76, 'imagens/arctic280img3.jpg', '2026-05-18 21:58:30'),
(12, 75, 'imagens/arcticproimg3.jpg', '2026-05-18 22:22:22'),
(13, 75, 'imagens/arcticproimg4.jpg', '2026-05-18 22:22:44'),
(14, 74, 'imagens/corsair4000img2.jpg', '2026-05-18 22:24:09'),
(15, 74, 'imagens/corsair4000img3.jpg', '2026-05-18 22:24:32'),
(16, 73, 'imagens/nzxth5img2.webp', '2026-05-18 22:26:17'),
(17, 73, 'imagens/nzxth5img3.jpg', '2026-05-18 22:26:32'),
(18, 72, 'imagens/nzxth9img2.jpg', '2026-05-18 22:28:10'),
(19, 72, 'imagens/nzxth9img3.jpg', '2026-05-18 22:28:27'),
(20, 40, 'imagens/bequiet650wimg2.jpg', '2026-05-18 22:31:13'),
(21, 40, 'imagens/bequiet650wimg3.jpg', '2026-05-18 22:31:28'),
(22, 39, 'imagens/corsairhx1500iimg2.jpg', '2026-05-18 22:33:26'),
(23, 39, 'imagens/corsairhx1500iimg3.jpg', '2026-05-18 22:33:41'),
(24, 39, 'imagens/corsairhx1500iimg4.jpg', '2026-05-18 22:33:57'),
(25, 38, 'imagens/evga750wimg2.png', '2026-05-18 22:36:56'),
(26, 38, 'imagens/evga750wimg3.png', '2026-05-18 22:37:12'),
(27, 38, 'imagens/evga750wimg4.png', '2026-05-18 22:37:27'),
(28, 35, 'imagens/corsair123img2.jpg', '2026-05-18 22:42:05'),
(29, 35, 'imagens/corsair123img3.jpg', '2026-05-18 22:42:19'),
(30, 34, 'imagens/noctuaimg2.jpg', '2026-05-19 17:51:45'),
(31, 34, 'imagens/noctuaimg3.jpg', '2026-05-19 17:52:03'),
(32, 32, 'imagens/corsairicueimg2.jpg', '2026-05-19 17:53:09'),
(33, 32, 'imagens/corsairicueimg3.jpg', '2026-05-19 17:53:24'),
(36, 31, 'imagens/nzxth7img2.jpg', '2026-05-19 17:55:23'),
(37, 31, 'imagens/nzxth7img3.jpg', '2026-05-19 17:55:39'),
(38, 30, 'imagens/lianli011img2.jpg', '2026-05-19 18:01:23'),
(39, 30, 'imagens/lianli011img3.jpg', '2026-05-19 18:01:39'),
(40, 29, 'imagens/bequietdarkimg2.webp', '2026-05-19 18:03:08'),
(41, 29, 'imagens/bequietdarkimg3.webp', '2026-05-19 18:03:23'),
(42, 28, 'imagens/seasonicimg2.jpg', '2026-05-19 18:04:36'),
(43, 28, 'imagens/seasonicimg3.jpg', '2026-05-19 18:05:03'),
(44, 27, 'imagens/corsairrmimg2.webp', '2026-05-19 18:06:29'),
(45, 27, 'imagens/corsairrmimg3.webp', '2026-05-19 18:06:46'),
(46, 26, 'imagens/aorusb650img2.webp', '2026-05-19 18:08:32'),
(47, 26, 'imagens/aorusb650img3.webp', '2026-05-19 18:08:45'),
(48, 25, 'imagens/rogx670img2.webp', '2026-05-19 18:15:37'),
(49, 25, 'imagens/rogx670img3.webp', '2026-05-19 18:15:55'),
(50, 23, 'imagens/z790img2.avif', '2026-05-19 18:17:29'),
(51, 23, 'imagens/z790img3.avif', '2026-05-19 18:17:45'),
(52, 22, 'imagens/barracudaimg2.webp', '2026-05-19 18:18:45'),
(53, 22, 'imagens/barracudaimg3.webp', '2026-05-19 18:18:58'),
(54, 21, 'imagens/samsungimg2.jpg', '2026-05-19 18:56:25'),
(55, 21, 'imagens/samsungimg3.jpg', '2026-05-19 18:56:40'),
(56, 19, 'imagens/wdblacksnimg2.webp', '2026-05-20 10:52:56'),
(57, 18, 'imagens/samsung2tbimg2.jpg', '2026-05-20 10:54:21'),
(58, 18, 'imagens/samsung2tbimg3.jpg', '2026-05-20 10:54:35'),
(59, 17, 'imagens/gskilltridentimg2.webp', '2026-05-20 10:55:45'),
(60, 17, 'imagens/gskilltridentimg3.webp', '2026-05-20 10:56:08'),
(61, 16, 'imagens/vengeance32gbimg3.avif', '2026-05-20 10:57:34'),
(62, 15, 'imagens/FURYDDR5img2.jpg', '2026-05-20 10:58:51'),
(63, 15, 'imagens/FURYDDR5img3.jpg', '2026-05-20 10:59:04'),
(64, 14, 'imagens/tridentddr5img2.webp', '2026-05-20 11:00:25'),
(65, 14, 'imagens/tridentddr5img3.webp', '2026-05-20 11:00:39'),
(66, 13, 'imagens/dominatorimg2.avif', '2026-05-20 11:02:17'),
(67, 13, 'imagens/dominatorimg3.avif', '2026-05-20 11:02:35'),
(68, 12, 'imagens/rx7600xtimg2.webp', '2026-05-20 11:06:08'),
(69, 12, 'imagens/rx7600xtimg3.webp', '2026-05-20 11:06:21'),
(72, 11, 'imagens/rx7900xtimg2.jpg', '2026-05-20 11:09:48'),
(73, 11, 'imagens/rx7900xtimg3.jpg', '2026-05-20 11:10:00'),
(74, 10, 'imagens/rtx4070superimg2.webp', '2026-05-20 11:12:52'),
(75, 9, 'imagens/rtx4070tisuperimg2.jpg', '2026-05-20 11:14:22'),
(76, 9, 'imagens/rtx4070tisuperimg3.jpg', '2026-05-20 11:14:37'),
(77, 8, 'imagens/rtx4080superimg2.webp', '2026-05-20 11:17:32'),
(78, 8, 'imagens/rtx4080superimg3.webp', '2026-05-20 11:17:49'),
(79, 7, 'imagens/rtx4090img2.jpg', '2026-05-20 11:20:19'),
(80, 7, 'imagens/rtx4090img3.jpg', '2026-05-20 11:20:32'),
(81, 6, 'imagens/ryzen57600ximg2.jpg', '2026-05-20 11:22:27'),
(82, 6, 'imagens/ryzen57600ximg3.jpg', '2026-05-20 11:22:39'),
(83, 5, 'imagens/ryzen77800x3dimg2.jpg', '2026-05-20 11:23:40'),
(84, 5, 'imagens/ryzen77800x3dimg3.jpg', '2026-05-20 11:23:54'),
(85, 4, 'imagens/ryzen9img2.webp', '2026-05-20 11:25:52'),
(86, 4, 'imagens/ryzen9img3.webp', '2026-05-20 11:26:04'),
(87, 3, 'imagens/inteli5img2.jpg', '2026-05-20 11:27:07'),
(88, 2, 'imagens/inteli5img2.jpg', '2026-05-20 11:27:55'),
(89, 1, 'imagens/inteli5img2.jpg', '2026-05-20 11:28:29');

-- --------------------------------------------------------

--
-- Estrutura da tabela `reviews`
--

CREATE TABLE `reviews` (
  `id` int NOT NULL,
  `produto_id` int NOT NULL,
  `utilizador_id` int NOT NULL,
  `classificacao` tinyint NOT NULL,
  `titulo` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `comentario` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `data_criacao` timestamp NULL DEFAULT CURRENT_TIMESTAMP
) ;

-- --------------------------------------------------------

--
-- Estrutura da tabela `utilizadores`
--

CREATE TABLE `utilizadores` (
  `id` int NOT NULL,
  `nome` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `password` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `telefone` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `nif` varchar(9) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `data_registo` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `ativo` tinyint(1) DEFAULT '1',
  `role` enum('user','admin') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'user'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Extraindo dados da tabela `utilizadores`
--

INSERT INTO `utilizadores` (`id`, `nome`, `email`, `password`, `telefone`, `nif`, `data_registo`, `ativo`, `role`) VALUES
(6, 'admin', 'admin@hardwarept.pt', '$2b$10$Co0oGRtNiF7v5palN.claeZ1HRkf1IYUo783M4cCSlVf.xB5xTHEe', '987654321', '193684683', '2026-01-23 08:36:52', 1, 'admin');

--
-- Índices para tabelas despejadas
--

--
-- Índices para tabela `carrinho`
--
ALTER TABLE `carrinho`
  ADD PRIMARY KEY (`id`),
  ADD KEY `utilizador_id` (`utilizador_id`),
  ADD KEY `produto_id` (`produto_id`);

--
-- Índices para tabela `categorias`
--
ALTER TABLE `categorias`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `slug` (`slug`);

--
-- Índices para tabela `contactos`
--
ALTER TABLE `contactos`
  ADD PRIMARY KEY (`id`);

--
-- Índices para tabela `itens_pedido`
--
ALTER TABLE `itens_pedido`
  ADD PRIMARY KEY (`id`),
  ADD KEY `pedido_id` (`pedido_id`),
  ADD KEY `produto_id` (`produto_id`);

--
-- Índices para tabela `pedidos`
--
ALTER TABLE `pedidos`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `numero_pedido` (`numero_pedido`),
  ADD KEY `utilizador_id` (`utilizador_id`);

--
-- Índices para tabela `produtos`
--
ALTER TABLE `produtos`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `slug` (`slug`),
  ADD KEY `categoria_id` (`categoria_id`);

--
-- Índices para tabela `produto_imagens`
--
ALTER TABLE `produto_imagens`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_produto_id` (`produto_id`);

--
-- Índices para tabela `reviews`
--
ALTER TABLE `reviews`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_utilizador_produto` (`utilizador_id`,`produto_id`),
  ADD KEY `produto_id` (`produto_id`),
  ADD KEY `utilizador_id` (`utilizador_id`);

--
-- Índices para tabela `utilizadores`
--
ALTER TABLE `utilizadores`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`);

--
-- AUTO_INCREMENT de tabelas despejadas
--

--
-- AUTO_INCREMENT de tabela `carrinho`
--
ALTER TABLE `carrinho`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=86;

--
-- AUTO_INCREMENT de tabela `categorias`
--
ALTER TABLE `categorias`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT de tabela `contactos`
--
ALTER TABLE `contactos`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=17;

--
-- AUTO_INCREMENT de tabela `itens_pedido`
--
ALTER TABLE `itens_pedido`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=57;

--
-- AUTO_INCREMENT de tabela `pedidos`
--
ALTER TABLE `pedidos`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=58;

--
-- AUTO_INCREMENT de tabela `produtos`
--
ALTER TABLE `produtos`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=158;

--
-- AUTO_INCREMENT de tabela `produto_imagens`
--
ALTER TABLE `produto_imagens`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=90;

--
-- AUTO_INCREMENT de tabela `reviews`
--
ALTER TABLE `reviews`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de tabela `utilizadores`
--
ALTER TABLE `utilizadores`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=14;

--
-- Restrições para despejos de tabelas
--

--
-- Limitadores para a tabela `carrinho`
--
ALTER TABLE `carrinho`
  ADD CONSTRAINT `carrinho_ibfk_1` FOREIGN KEY (`utilizador_id`) REFERENCES `utilizadores` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `carrinho_ibfk_2` FOREIGN KEY (`produto_id`) REFERENCES `produtos` (`id`) ON DELETE CASCADE;

--
-- Limitadores para a tabela `itens_pedido`
--
ALTER TABLE `itens_pedido`
  ADD CONSTRAINT `itens_pedido_ibfk_1` FOREIGN KEY (`pedido_id`) REFERENCES `pedidos` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `itens_pedido_ibfk_2` FOREIGN KEY (`produto_id`) REFERENCES `produtos` (`id`) ON DELETE CASCADE;

--
-- Limitadores para a tabela `pedidos`
--
ALTER TABLE `pedidos`
  ADD CONSTRAINT `pedidos_ibfk_1` FOREIGN KEY (`utilizador_id`) REFERENCES `utilizadores` (`id`) ON DELETE CASCADE;

--
-- Limitadores para a tabela `produtos`
--
ALTER TABLE `produtos`
  ADD CONSTRAINT `produtos_ibfk_1` FOREIGN KEY (`categoria_id`) REFERENCES `categorias` (`id`) ON DELETE CASCADE;

--
-- Limitadores para a tabela `produto_imagens`
--
ALTER TABLE `produto_imagens`
  ADD CONSTRAINT `produto_imagens_ibfk_1` FOREIGN KEY (`produto_id`) REFERENCES `produtos` (`id`) ON DELETE CASCADE;

--
-- Limitadores para a tabela `reviews`
--
ALTER TABLE `reviews`
  ADD CONSTRAINT `reviews_ibfk_1` FOREIGN KEY (`produto_id`) REFERENCES `produtos` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `reviews_ibfk_2` FOREIGN KEY (`utilizador_id`) REFERENCES `utilizadores` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
