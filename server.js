const express = require('express');
const cors = require('cors');
const path = require('path');
const bcrypt = require('bcryptjs');
const session = require('express-session');
const mysql = require('mysql2');

const app = express();
const PORT = process.env.PORT || 3000;

const db = mysql.createPool({
  host: 'localhost',
  user: 'root',
  password: 'mysql',
  database: 'hardwarept',
  waitForConnections: true,
  connectionLimit: 10
});
console.log('✅ Pool MySQL criado – BD: hardwarept');

app.use(cors({
  origin: ['http://localhost:3000', 'http://127.0.0.1:3000'],
  credentials: true
}));

// Headers de segurança
app.disable('x-powered-by');
app.use((req, res, next) => {
  res.setHeader('X-Content-Type-Options', 'nosniff');
  res.setHeader('X-Frame-Options', 'SAMEORIGIN');
  res.setHeader('X-XSS-Protection', '1; mode=block');
  res.setHeader('Referrer-Policy', 'strict-origin-when-cross-origin');
  next();
});

app.use(express.json());
app.use(express.static(path.join(__dirname, 'public')));
app.use(session({
  secret: 'hardwarept-secret-key-2025',
  resave: false,
  saveUninitialized: false,
  cookie: { secure: false, httpOnly: true, maxAge: 24 * 60 * 60 * 1000, sameSite: 'lax', path: '/' },
  rolling: true
}));

function validarCodigoPostal(cp) {
  if (!cp) return false;
  return /^\d{4}-\d{3}$/.test(cp) || /^\d{7}$/.test(cp);
}

function validarNIF(nif) {
  if (!nif) return true;
  const n = String(nif).replace(/\s/g, '');
  if (!/^\d{9}$/.test(n)) return false;

  const primeiros = ['1','2','3','5','6','7','8','9','45','70','71','72','75','77','79','90','91','98','99'];
  const p2 = n.substring(0, 2);
  const p1 = n.charAt(0);
  if (!primeiros.some(p => p === p2 || p === p1)) return false;

  let soma = 0;
  for (let i = 0; i < 8; i++) soma += parseInt(n.charAt(i)) * (9 - i);
  const resto = soma % 11;
  const check = resto < 2 ? 0 : 11 - resto;
  return check === parseInt(n.charAt(8));
}

function requireAdmin(req, res, next) {
  if (!req.session.utilizador) return res.status(401).json({ erro: 'Não autenticado' });
  if (req.session.utilizador.role !== 'admin') return res.status(403).json({ erro: 'Acesso negado. Apenas administradores.' });
  next();
}

function requireAuth(req, res, next) {
  if (!req.session.utilizador) return res.status(401).json({ erro: 'Não autenticado' });
  next();
}

app.post('/api/auth/registo', async (req, res) => {
  console.log('📥 Registo recebido:', req.body);
  const { nome, email, password, telefone, nif } = req.body;

  if (!nome || !email || !password) {
    return res.status(400).json({ sucesso: false, mensagem: 'Preencha nome, email e password' });
  }

  if (nif && !validarNIF(nif)) {
    return res.status(400).json({ sucesso: false, mensagem: 'NIF inválido. Deve ter 9 dígitos e ser um NIF português válido.' });
  }

  try {
    const [rows] = await db.promise().query('SELECT id FROM utilizadores WHERE email = ?', [email]);
    if (rows.length > 0) return res.status(409).json({ sucesso: false, mensagem: 'Email já registado' });

    const hashedPassword = await bcrypt.hash(password, 10);
    const [result] = await db.promise().query(
      `INSERT INTO utilizadores (nome, email, password, telefone, nif, role) VALUES (?, ?, ?, ?, ?, 'user')`,
      [nome, email, hashedPassword, telefone || null, nif || null]
    );

    console.log('✅ Utilizador criado com ID:', result.insertId);
    res.json({ sucesso: true, mensagem: 'Registo efetuado com sucesso', utilizador: { id: result.insertId, nome, email, role: 'user' } });
  } catch (error) {
    console.error('❌ Erro no registo:', error.message);
    res.status(500).json({ sucesso: false, mensagem: 'Erro ao criar conta: ' + error.message });
  }
});

app.post('/api/auth/login', async (req, res) => {
  console.log('📥 LOGIN RECEBIDO:', req.body);
  const { email, password } = req.body;
  if (!email || !password) return res.status(400).json({ sucesso: false, mensagem: 'Preencha email e password' });

  try {
    const [rows] = await db.promise().query('SELECT * FROM utilizadores WHERE email = ?', [email]);
    if (rows.length === 0) return res.status(401).json({ sucesso: false, mensagem: 'Email ou password incorretos' });

    const user = rows[0];
    const match = await bcrypt.compare(password, user.password);
    if (!match) return res.status(401).json({ sucesso: false, mensagem: 'Email ou password incorretos' });

    req.session.utilizador = { id: user.id, nome: user.nome, email: user.email, role: user.role || 'user' };
    res.json({ sucesso: true, mensagem: 'Login efetuado', utilizador: { id: user.id, nome: user.nome, email: user.email, role: user.role || 'user' } });
  } catch (error) {
    console.error('Erro no login:', error.message);
    res.status(500).json({ sucesso: false, mensagem: 'Erro no servidor' });
  }
});

app.get('/api/auth/verificar', (req, res) => {
  if (req.session && req.session.utilizador) {
    res.json({ autenticado: true, utilizador: req.session.utilizador });
  } else {
    res.json({ autenticado: false });
  }
});

app.post('/api/auth/logout', (req, res) => {
  req.session.destroy((err) => {
    if (err) return res.status(500).json({ error: 'Erro ao fazer logout' });
    res.clearCookie('connect.sid');
    res.json({ success: true });
  });
});

app.get('/api/utilizador/:id', (req, res) => {
  const id = req.params.id;
  db.query('SELECT id, nome, email, telefone, role FROM utilizadores WHERE id = ?', [id], (err, results) => {
    if (err) return res.status(500).json({ sucesso: false, mensagem: 'Erro no servidor' });
    if (results.length === 0) return res.status(404).json({ sucesso: false, mensagem: 'Utilizador não encontrado' });
    res.json({ sucesso: true, utilizador: results[0] });
  });
});

app.get('/api/utilizador', async (req, res) => {
  if (!req.session.utilizador) return res.status(401).json({ erro: 'Não autenticado' });
  const userId = req.session.utilizador.id;
  try {
    const [users] = await db.promise().query(
      'SELECT nome, email, telefone, nif, role FROM utilizadores WHERE id = ?',
      [userId]
    );
    if (users.length === 0) return res.status(404).json({ erro: 'Utilizador não encontrado' });
    res.json(users[0]);
  } catch (error) {
    console.error('❌ Erro ao obter dados do utilizador:', error);
    res.status(500).json({ erro: 'Erro ao obter dados do utilizador' });
  }
});

app.get('/api/produtos', (req, res) => {
  const query = `
    SELECT p.id, p.nome, p.slug, p.preco, p.preco_promocional,
        p.categoria_id, c.nome as categoria, c.slug as categoria_slug,
        p.imagem, p.stock, p.em_promocao,
        p.especificacoes, p.especificacoes_tecnicas,
        p.destaque, p.ativo
    FROM produtos p
    LEFT JOIN categorias c ON p.categoria_id = c.id
    WHERE p.ativo = 1
    ORDER BY p.id DESC
  `;
  db.query(query, (error, results) => {
    if (error) return res.status(500).json({ error: 'Erro ao buscar produtos' });
    console.log(`✅ ${results.length} produtos encontrados`);
    res.json(results);
  });
});

app.get('/api/produtos/destaque', (req, res) => {
  const query = `
    SELECT p.id, p.nome, p.slug, p.preco, p.preco_promocional,
        p.categoria_id, c.nome AS categoria, c.slug AS categoria_slug,
        p.imagem, p.stock, p.especificacoes, p.especificacoes_tecnicas,
        p.caracteristicas, p.em_promocao, p.destaque
    FROM produtos p
    LEFT JOIN categorias c ON p.categoria_id = c.id
    WHERE p.destaque = 1 AND p.ativo = 1
    ORDER BY p.id DESC LIMIT 12
  `;
  db.query(query, (error, results) => {
    if (error) return res.status(500).json({ error: 'Erro ao buscar produtos em destaque' });
    res.json(results);
  });
});

app.get('/api/produtos/promocao', (req, res) => {
  const query = `
    SELECT p.id, p.nome, p.slug, p.preco, p.preco_promocional,
        p.categoria_id, c.nome AS categoria, c.slug AS categoria_slug,
        p.imagem, p.stock, p.em_promocao
    FROM produtos p
    LEFT JOIN categorias c ON p.categoria_id = c.id
    WHERE p.em_promocao = 1 AND p.ativo = 1
    ORDER BY p.id DESC
  `;
  db.query(query, (error, results) => {
    if (error) return res.status(500).json({ error: 'Erro ao buscar produtos em promoção' });
    res.json(results);
  });
});

app.get('/api/produtos/:id', (req, res) => {
  const { id } = req.params;
  const query = `SELECT p.*, c.nome AS categoria, c.slug AS categoria_slug FROM produtos p LEFT JOIN categorias c ON p.categoria_id = c.id WHERE p.id = ?`;
  db.query(query, [id], (error, results) => {
    if (error) return res.status(500).json({ error: 'Erro ao buscar produto' });
    if (results.length === 0) return res.status(404).json({ error: 'Produto não encontrado' });
    res.json(results[0]);
  });
});

app.get('/api/produtos/:id/imagens', (req, res) => {
  const { id } = req.params;
  db.query(
    'SELECT id, url FROM produto_imagens WHERE produto_id = ?',
    [id],
    (error, results) => {
      if (error) return res.status(500).json({ erro: 'Erro ao buscar imagens' });
      res.json(results);
    }
  );
});

app.post('/api/admin/produtos/:id/imagens', requireAdmin, async (req, res) => {
  const { id } = req.params;
  const { url } = req.body;
  if (!url) return res.status(400).json({ erro: 'URL obrigatório' });
  try {
    const [result] = await db.promise().query(
      'INSERT INTO produto_imagens (produto_id, url) VALUES (?, ?)',
      [id, url]
    );
    res.json({ sucesso: true, id: result.insertId });
  } catch (err) {
    res.status(500).json({ erro: 'Erro ao adicionar imagem' });
  }
});

app.delete('/api/admin/imagens/:id', requireAdmin, async (req, res) => {
  const { id } = req.params;
  try {
    await db.promise().query('DELETE FROM produto_imagens WHERE id = ?', [id]);
    res.json({ sucesso: true });
  } catch (err) {
    res.status(500).json({ erro: 'Erro ao remover imagem' });
  }
});

app.get('/api/categorias', (req, res) => {
  db.query('SELECT id, nome, slug, icone FROM categorias ORDER BY nome', (error, results) => {
    if (error) return res.status(500).json({ error: 'Erro ao buscar categorias' });
    res.json(results);
  });
});

app.get('/api/categorias/:slug', (req, res) => {
  const { slug } = req.params;
  db.query('SELECT * FROM categorias WHERE slug = ?', [slug], (error, results) => {
    if (error) return res.status(500).json({ error: 'Erro ao buscar categoria' });
    if (results.length === 0) return res.status(404).json({ error: 'Categoria não encontrada' });
    res.json(results[0]);
  });
});

app.post('/api/carrinho/adicionar', async (req, res) => {
  if (!req.session.utilizador) return res.status(401).json({ erro: 'Não autenticado' });
  const { produto_id, quantidade } = req.body;
  const utilizador_id = req.session.utilizador.id;
  if (!produto_id || !quantidade || quantidade <= 0) return res.status(400).json({ erro: 'Dados inválidos' });

  try {
    const [produto] = await db.promise().query('SELECT id, stock FROM produtos WHERE id = ? AND ativo = 1', [produto_id]);
    if (produto.length === 0) return res.status(404).json({ erro: 'Produto não encontrado ou inativo' });
    if (produto[0].stock < quantidade) return res.status(400).json({ erro: 'Stock insuficiente' });

    const [existente] = await db.promise().query('SELECT id, quantidade FROM carrinho WHERE utilizador_id = ? AND produto_id = ?', [utilizador_id, produto_id]);
    if (existente.length > 0) {
      const novaQuantidade = existente[0].quantidade + quantidade;
      if (produto[0].stock < novaQuantidade) return res.status(400).json({ erro: 'Stock insuficiente para essa quantidade' });
      await db.promise().query('UPDATE carrinho SET quantidade = ? WHERE id = ?', [novaQuantidade, existente[0].id]);
      res.json({ sucesso: true, mensagem: 'Quantidade atualizada no carrinho' });
    } else {
      await db.promise().query('INSERT INTO carrinho (utilizador_id, produto_id, quantidade) VALUES (?, ?, ?)', [utilizador_id, produto_id, quantidade]);
      res.json({ sucesso: true, mensagem: 'Produto adicionado ao carrinho' });
    }
  } catch (error) {
    console.error('❌ Erro ao adicionar ao carrinho:', error);
    res.status(500).json({ erro: 'Erro ao adicionar ao carrinho' });
  }
});

app.get('/api/carrinho', async (req, res) => {
  if (!req.session.utilizador) return res.status(401).json({ erro: 'Não autenticado' });
  const utilizador_id = req.session.utilizador.id;
  try {
    const [items] = await db.promise().query(`
      SELECT c.id, c.produto_id, c.quantidade,
             p.nome, p.preco, p.preco_promocional, p.imagem, p.stock
      FROM carrinho c
      INNER JOIN produtos p ON c.produto_id = p.id
      WHERE c.utilizador_id = ? AND p.ativo = 1
      ORDER BY c.id DESC
    `, [utilizador_id]);
    res.json(items);
  } catch (error) {
    console.error('❌ Erro ao obter carrinho:', error);
    res.status(500).json({ erro: 'Erro ao obter carrinho' });
  }
});

app.put('/api/carrinho/:id', async (req, res) => {
  if (!req.session.utilizador) return res.status(401).json({ erro: 'Não autenticado' });
  const { id } = req.params;
  const { quantidade } = req.body;
  const utilizador_id = req.session.utilizador.id;
  if (!quantidade || quantidade <= 0) return res.status(400).json({ erro: 'Quantidade inválida' });

  try {
    const [item] = await db.promise().query(`
      SELECT c.id, p.stock FROM carrinho c INNER JOIN produtos p ON c.produto_id = p.id
      WHERE c.id = ? AND c.utilizador_id = ?
    `, [id, utilizador_id]);
    if (item.length === 0) return res.status(404).json({ erro: 'Item não encontrado no carrinho' });
    if (item[0].stock < quantidade) return res.status(400).json({ erro: 'Stock insuficiente' });
    await db.promise().query('UPDATE carrinho SET quantidade = ? WHERE id = ?', [quantidade, id]);
    res.json({ sucesso: true, mensagem: 'Quantidade atualizada' });
  } catch (error) {
    console.error('❌ Erro ao atualizar carrinho:', error);
    res.status(500).json({ erro: 'Erro ao atualizar carrinho' });
  }
});

app.delete('/api/carrinho/:id', async (req, res) => {
  if (!req.session.utilizador) return res.status(401).json({ erro: 'Não autenticado' });
  const { id } = req.params;
  const utilizador_id = req.session.utilizador.id;
  try {
    const [result] = await db.promise().query('DELETE FROM carrinho WHERE id = ? AND utilizador_id = ?', [id, utilizador_id]);
    if (result.affectedRows === 0) return res.status(404).json({ erro: 'Item não encontrado no carrinho' });
    res.json({ sucesso: true, mensagem: 'Item removido do carrinho' });
  } catch (error) {
    console.error('❌ Erro ao remover do carrinho:', error);
    res.status(500).json({ erro: 'Erro ao remover do carrinho' });
  }
});

app.delete('/api/carrinho', async (req, res) => {
  if (!req.session.utilizador) return res.status(401).json({ erro: 'Não autenticado' });
  const utilizador_id = req.session.utilizador.id;
  try {
    await db.promise().query('DELETE FROM carrinho WHERE utilizador_id = ?', [utilizador_id]);
    res.json({ sucesso: true, mensagem: 'Carrinho limpo' });
  } catch (error) {
    console.error('❌ Erro ao limpar carrinho:', error);
    res.status(500).json({ erro: 'Erro ao limpar carrinho' });
  }
});

app.post('/api/pedidos', async (req, res) => {
  console.log('📥 POST /api/pedidos');

  if (!req.session.utilizador) return res.status(401).json({ erro: 'Não autenticado' });

  const utilizador_id = req.session.utilizador.id;
  const {
    nome_envio, email_envio, telefone_envio, nif_envio,
    morada_envio, cidade_envio, codigo_postal_envio,
    metodo_pagamento, items
  } = req.body;

  if (!nome_envio || !email_envio || !telefone_envio || !morada_envio || !cidade_envio || !codigo_postal_envio || !metodo_pagamento || !items || items.length === 0) {
    return res.status(400).json({ erro: 'Dados incompletos' });
  }

  if (!validarCodigoPostal(codigo_postal_envio)) {
    return res.status(400).json({ erro: 'Código postal inválido. Use o formato XXXX-XXX (ex: 1000-001)' });
  }

  if (nif_envio && !validarNIF(nif_envio)) {
    return res.status(400).json({ erro: 'NIF inválido. Deve ter 9 dígitos e ser um NIF português válido.' });
  }

  try {
    let subtotalCalculado = 0;
    for (const item of items) {
      const [produto] = await db.promise().query('SELECT preco, preco_promocional, stock FROM produtos WHERE id = ?', [item.produto_id]);
      if (produto.length === 0) return res.status(404).json({ erro: `Produto ${item.produto_id} não encontrado` });
      if (produto[0].stock < item.quantidade) return res.status(400).json({ erro: `Stock insuficiente para produto ${item.produto_id}` });
      const preco = parseFloat(produto[0].preco_promocional || produto[0].preco);
      subtotalCalculado += preco * item.quantidade;
    }

    subtotalCalculado = Math.round(subtotalCalculado * 100) / 100;
    const ivaCalculado = Math.round(subtotalCalculado * 0.23 * 100) / 100;
    const totalCalculado = Math.round((subtotalCalculado + ivaCalculado) * 100) / 100;

    const numero_pedido = `PED-${Date.now()}-${utilizador_id}`;

    const [pedidoResult] = await db.promise().query(
      `INSERT INTO pedidos 
        (utilizador_id, numero_pedido, nome_envio, email_envio, telefone_envio, nif_envio,
         morada_envio, cidade_envio, codigo_postal_envio, metodo_pagamento,
         subtotal, iva, total, estado)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'pendente')`,
      [utilizador_id, numero_pedido, nome_envio, email_envio, telefone_envio, nif_envio || null,
       morada_envio, cidade_envio, codigo_postal_envio, metodo_pagamento,
       subtotalCalculado, ivaCalculado, totalCalculado]
    );

    const pedido_id = pedidoResult.insertId;

    for (const item of items) {
      const [produto] = await db.promise().query('SELECT preco, preco_promocional FROM produtos WHERE id = ?', [item.produto_id]);
      const preco = parseFloat(produto[0].preco_promocional || produto[0].preco);
      const subtotal = Math.round(preco * item.quantidade * 100) / 100;
      await db.promise().query(
        'INSERT INTO itens_pedido (pedido_id, produto_id, quantidade, preco_unitario, subtotal) VALUES (?, ?, ?, ?, ?)',
        [pedido_id, item.produto_id, item.quantidade, preco, subtotal]
      );
      await db.promise().query('UPDATE produtos SET stock = stock - ? WHERE id = ?', [item.quantidade, item.produto_id]);
    }

    await db.promise().query('DELETE FROM carrinho WHERE utilizador_id = ?', [utilizador_id]);

    console.log(`✅ Pedido ${numero_pedido} criado | Subtotal: €${subtotalCalculado} | IVA: €${ivaCalculado} | Total: €${totalCalculado}`);

    res.json({
      sucesso: true,
      mensagem: 'Pedido criado com sucesso',
      id: pedido_id,
      pedido_id,
      numero_pedido,
      subtotal: subtotalCalculado,
      iva: ivaCalculado,
      total: totalCalculado,
      data_criacao: new Date().toISOString()
    });

  } catch (error) {
    console.error('❌ Erro ao criar pedido:', error);
    res.status(500).json({ erro: 'Erro ao criar pedido' });
  }
});

app.get('/api/pedidos', async (req, res) => {
  if (!req.session.utilizador) return res.status(401).json({ erro: 'Não autenticado' });
  const utilizador_id = req.session.utilizador.id;
  try {
    const [pedidos] = await db.promise().query(`
      SELECT p.id, p.numero_pedido, p.total, p.subtotal, p.iva, p.estado, p.data_criacao,
             p.nome_envio, p.morada_envio, p.cidade_envio,
             COUNT(pi.id) as total_items
      FROM pedidos p
      LEFT JOIN itens_pedido pi ON p.id = pi.pedido_id
      WHERE p.utilizador_id = ?
      GROUP BY p.id
      ORDER BY p.data_criacao DESC
    `, [utilizador_id]);
    res.json(pedidos);
  } catch (error) {
    console.error('❌ Erro ao obter pedidos:', error);
    res.status(500).json({ erro: 'Erro ao obter pedidos' });
  }
});

app.get('/api/pedidos/:id', async (req, res) => {
  if (!req.session.utilizador) return res.status(401).json({ erro: 'Não autenticado' });
  const { id } = req.params;
  const utilizador_id = req.session.utilizador.id;
  try {
    const [pedidos] = await db.promise().query('SELECT * FROM pedidos WHERE id = ? AND utilizador_id = ?', [id, utilizador_id]);
    if (pedidos.length === 0) return res.status(404).json({ erro: 'Pedido não encontrado' });
    const [items] = await db.promise().query(`
      SELECT pi.*, p.nome, p.imagem FROM itens_pedido pi
      INNER JOIN produtos p ON pi.produto_id = p.id WHERE pi.pedido_id = ?
    `, [id]);
    const pedido = pedidos[0];
    pedido.items = items;
    res.json(pedido);
  } catch (error) {
    console.error('❌ Erro ao obter pedido:', error);
    res.status(500).json({ erro: 'Erro ao obter pedido' });
  }
});

app.get('/api/produtos/:id/reviews', async (req, res) => {
  const { id } = req.params;
  try {
    const [reviews] = await db.promise().query(`
      SELECT r.id, r.classificacao, r.titulo, r.comentario, r.data_criacao,
             u.nome AS utilizador_nome,
             -- Verificar se o review pertence ao utilizador atual (para botão de apagar)
             IF(r.utilizador_id = ?, 1, 0) AS e_meu
      FROM reviews r
      INNER JOIN utilizadores u ON r.utilizador_id = u.id
      WHERE r.produto_id = ?
      ORDER BY r.data_criacao DESC
    `, [req.session.utilizador?.id || 0, id]);

    const [stats] = await db.promise().query(`
      SELECT 
        COUNT(*) AS total,
        ROUND(AVG(classificacao), 1) AS media,
        SUM(classificacao = 5) AS cinco,
        SUM(classificacao = 4) AS quatro,
        SUM(classificacao = 3) AS tres,
        SUM(classificacao = 2) AS dois,
        SUM(classificacao = 1) AS um
      FROM reviews
      WHERE produto_id = ?
    `, [id]);

    res.json({ reviews, stats: stats[0] });
  } catch (error) {
    console.error('❌ Erro ao obter reviews:', error);
    res.status(500).json({ erro: 'Erro ao obter reviews' });
  }
});

app.post('/api/produtos/:id/reviews', requireAuth, async (req, res) => {
  const produto_id = req.params.id;
  const utilizador_id = req.session.utilizador.id;
  const { classificacao, titulo, comentario } = req.body;

  if (!classificacao || classificacao < 1 || classificacao > 5) {
    return res.status(400).json({ erro: 'Classificação deve ser entre 1 e 5' });
  }
  if (!comentario || comentario.trim().length < 10) {
    return res.status(400).json({ erro: 'O comentário deve ter pelo menos 10 caracteres' });
  }
  if (titulo && titulo.length > 100) {
    return res.status(400).json({ erro: 'O título não pode ter mais de 100 caracteres' });
  }

  try {
    const [produto] = await db.promise().query('SELECT id FROM produtos WHERE id = ? AND ativo = 1', [produto_id]);
    if (produto.length === 0) return res.status(404).json({ erro: 'Produto não encontrado' });

    const [existente] = await db.promise().query(
      'SELECT id FROM reviews WHERE utilizador_id = ? AND produto_id = ?',
      [utilizador_id, produto_id]
    );
    if (existente.length > 0) {
      return res.status(409).json({ erro: 'Já avaliou este produto. Só é permitida uma avaliação por produto.' });
    }

    const [result] = await db.promise().query(
      `INSERT INTO reviews (produto_id, utilizador_id, classificacao, titulo, comentario)
       VALUES (?, ?, ?, ?, ?)`,
      [produto_id, utilizador_id, parseInt(classificacao), titulo?.trim() || null, comentario.trim()]
    );

    console.log(`✅ Review criada: produto ${produto_id} por user ${utilizador_id}`);
    res.status(201).json({ sucesso: true, mensagem: 'Avaliação publicada com sucesso!', id: result.insertId });
  } catch (error) {
    console.error('❌ Erro ao criar review:', error);
    res.status(500).json({ erro: 'Erro ao criar avaliação' });
  }
});

app.delete('/api/reviews/:id', requireAuth, async (req, res) => {
  const { id } = req.params;
  const utilizador_id = req.session.utilizador.id;
  const isAdmin = req.session.utilizador.role === 'admin';

  try {
    const [reviews] = await db.promise().query('SELECT utilizador_id FROM reviews WHERE id = ?', [id]);
    if (reviews.length === 0) return res.status(404).json({ erro: 'Review não encontrada' });
    if (!isAdmin && reviews[0].utilizador_id !== utilizador_id) {
      return res.status(403).json({ erro: 'Não tem permissão para apagar esta avaliação' });
    }
    await db.promise().query('DELETE FROM reviews WHERE id = ?', [id]);
    res.json({ sucesso: true, mensagem: 'Avaliação removida' });
  } catch (error) {
    console.error('❌ Erro ao apagar review:', error);
    res.status(500).json({ erro: 'Erro ao apagar avaliação' });
  }
});

app.put('/api/utilizador/atualizar', async (req, res) => {
  if (!req.session.utilizador) return res.status(401).json({ sucesso: false, mensagem: 'Não autenticado' });
  const userId = req.session.utilizador.id;
  const { nome, email, telefone, nif } = req.body;

  if (nif && !validarNIF(nif)) {
    return res.status(400).json({ sucesso: false, mensagem: 'NIF inválido. Deve ter 9 dígitos e ser um NIF português válido.' });
  }

  try {
    if (email !== req.session.utilizador.email) {
      const [emailExists] = await db.promise().query('SELECT id FROM utilizadores WHERE email = ? AND id != ?', [email, userId]);
      if (emailExists.length > 0) return res.status(409).json({ sucesso: false, mensagem: 'Este email já está a ser utilizado' });
    }
    await db.promise().query(
      `UPDATE utilizadores SET nome = ?, email = ?, telefone = ?, nif = ? WHERE id = ?`,
      [nome, email, telefone || null, nif || null, userId]
    );
    if (nome !== req.session.utilizador.nome || email !== req.session.utilizador.email) {
      req.session.utilizador.nome = nome;
      req.session.utilizador.email = email;
    }
    res.json({ sucesso: true, mensagem: 'Perfil atualizado com sucesso!' });
  } catch (error) {
    console.error('❌ Erro ao atualizar perfil:', error);
    res.status(500).json({ sucesso: false, mensagem: 'Erro ao atualizar perfil' });
  }
});

app.put('/api/utilizador/alterar-password', async (req, res) => {
  if (!req.session.utilizador) return res.status(401).json({ sucesso: false, mensagem: 'Não autenticado' });
  const userId = req.session.utilizador.id;
  const { passwordAtual, passwordNova } = req.body;
  if (!passwordAtual || !passwordNova) return res.status(400).json({ sucesso: false, mensagem: 'Preencha todos os campos' });
  if (passwordNova.length < 8) return res.status(400).json({ sucesso: false, mensagem: 'A password deve ter pelo menos 8 caracteres' });

  try {
    const [users] = await db.promise().query('SELECT password FROM utilizadores WHERE id = ?', [userId]);
    if (users.length === 0) return res.status(404).json({ sucesso: false, mensagem: 'Utilizador não encontrado' });
    const passwordCorreta = await bcrypt.compare(passwordAtual, users[0].password);
    if (!passwordCorreta) return res.status(401).json({ sucesso: false, mensagem: 'Password atual incorreta' });
    const hashedPassword = await bcrypt.hash(passwordNova, 10);
    await db.promise().query('UPDATE utilizadores SET password = ? WHERE id = ?', [hashedPassword, userId]);
    res.json({ sucesso: true, mensagem: 'Password alterada com sucesso!' });
  } catch (error) {
    console.error('❌ Erro ao alterar password:', error);
    res.status(500).json({ sucesso: false, mensagem: 'Erro ao alterar password' });
  }
});

app.post('/api/contacto', async (req, res) => {
  const { nome, email, telefone, assunto, mensagem } = req.body;
  if (!nome || !email || !assunto || !mensagem) return res.status(400).json({ sucesso: false, mensagem: 'Por favor preencha todos os campos obrigatórios' });
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  if (!emailRegex.test(email)) return res.status(400).json({ sucesso: false, mensagem: 'Email inválido' });
  const assuntosValidos = ['compatibilidade', 'produto', 'orcamento', 'encomenda', 'montagem', 'garantia', 'devolucao', 'empresas', 'outro'];
  if (!assuntosValidos.includes(assunto)) return res.status(400).json({ sucesso: false, mensagem: 'Assunto inválido' });

  try {
    const [result] = await db.promise().query(
      `INSERT INTO contactos (nome, email, telefone, assunto, mensagem, estado) VALUES (?, ?, ?, ?, ?, 'novo')`,
      [nome, email, telefone || null, assunto, mensagem]
    );
    res.json({ sucesso: true, mensagem: 'Mensagem enviada com sucesso! Entraremos em contacto em breve.', id: result.insertId });
  } catch (error) {
    console.error('❌ Erro ao guardar contacto:', error.message);
    res.status(500).json({ sucesso: false, mensagem: 'Erro ao enviar mensagem. Tente novamente mais tarde.' });
  }
});

app.get('/api/admin/produtos', requireAdmin, async (req, res) => {
  try {
    const [produtos] = await db.promise().query(`
      SELECT p.id, p.nome, p.slug, p.preco, p.preco_promocional, p.stock,
             p.imagem, p.especificacoes, p.especificacoes_tecnicas, p.caracteristicas,
             p.categoria_id, c.nome AS categoria, c.slug AS categoria_slug,
             p.em_promocao, p.destaque, p.ativo
      FROM produtos p LEFT JOIN categorias c ON p.categoria_id = c.id ORDER BY p.id DESC
    `);
    res.json(produtos);
  } catch (err) {
    res.status(500).json({ erro: 'Erro ao buscar produtos' });
  }
});

app.post('/api/admin/produtos', requireAdmin, async (req, res) => {
  const { nome, slug, preco, preco_promocional, categoria_id, stock, imagem, especificacoes, especificacoes_tecnicas, caracteristicas, em_promocao, destaque, ativo } = req.body;
  if (!nome || !preco || !categoria_id) return res.status(400).json({ erro: 'Nome, preço e categoria são obrigatórios' });
  try {
    const [result] = await db.promise().query(
      `INSERT INTO produtos (nome, slug, preco, preco_promocional, categoria_id, stock, imagem, especificacoes, especificacoes_tecnicas, caracteristicas, em_promocao, destaque, ativo)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      [nome, slug || null, preco, preco_promocional || null, categoria_id, stock || 0, imagem || null, especificacoes || null, especificacoes_tecnicas ? JSON.stringify(especificacoes_tecnicas) : null, caracteristicas ? JSON.stringify(caracteristicas) : null, em_promocao ? 1 : 0, destaque ? 1 : 0, ativo ? 1 : 0]
    );
    res.json({ sucesso: true, mensagem: 'Produto criado', id: result.insertId });
    } catch (err) {
      if (err.code === 'ER_DUP_ENTRY') {
        return res.status(400).json({ erro: 'Já existe um produto com esse nome' });
      }
      res.status(500).json({ erro: 'Erro ao criar produto' });
    }
});

app.put('/api/admin/produtos/:id', requireAdmin, async (req, res) => {
  const { id } = req.params;
  const { nome, preco, preco_promocional, categoria_id, stock, imagem, especificacoes, especificacoes_tecnicas, caracteristicas, em_promocao, destaque, ativo } = req.body;
  try {
    await db.promise().query(
      `UPDATE produtos SET nome=?, preco=?, preco_promocional=?, categoria_id=?, stock=?, imagem=?, especificacoes=?, especificacoes_tecnicas=?, caracteristicas=?, em_promocao=?, destaque=?, ativo=? WHERE id=?`,
      [nome, preco, preco_promocional || null, categoria_id, stock ?? 0, imagem, especificacoes, especificacoes_tecnicas ? JSON.stringify(especificacoes_tecnicas) : null, caracteristicas ? JSON.stringify(caracteristicas) : null, em_promocao ? 1 : 0, destaque ? 1 : 0, ativo !== undefined ? (ativo ? 1 : 0) : 1, id]
    );
    res.json({ sucesso: true, mensagem: 'Produto atualizado' });
  } catch (err) {
    console.error('Erro ao atualizar produto:', err.message);
    res.status(500).json({ erro: 'Erro ao atualizar produto' });
  }
});

app.patch('/api/admin/produtos/:id/ativo', requireAdmin, async (req, res) => {
  const { id } = req.params;
  const { ativo } = req.body;
  try {
    await db.promise().query('UPDATE produtos SET ativo = ? WHERE id = ?', [ativo ? 1 : 0, id]);
    res.json({ sucesso: true, mensagem: 'Estado atualizado' });
  } catch (err) {
    res.status(500).json({ erro: 'Erro ao atualizar estado do produto' });
  }
});

app.patch('/api/admin/produtos/:id/promocao', requireAdmin, async (req, res) => {
  const { id } = req.params;
  const { preco_promocional } = req.body;
  const emPromocao = (preco_promocional !== null && preco_promocional !== undefined) ? 1 : 0;
  try {
    await db.promise().query(
      'UPDATE produtos SET preco_promocional = ?, em_promocao = ? WHERE id = ?',
      [preco_promocional || null, emPromocao, id]
    );
    res.json({ sucesso: true, mensagem: emPromocao ? 'Promoção aplicada' : 'Promoção removida' });
  } catch (err) {
    res.status(500).json({ erro: 'Erro ao atualizar promoção' });
  }
});

app.delete('/api/admin/produtos/:id', requireAdmin, async (req, res) => {
  const { id } = req.params;
  try {
    await db.promise().query('DELETE FROM produtos WHERE id = ?', [id]);
    res.json({ sucesso: true, mensagem: 'Produto removido' });
  } catch (err) {
    res.status(500).json({ erro: 'Erro ao remover produto' });
  }
});

app.get('/api/admin/encomendas', requireAdmin, async (req, res) => {
  try {
    const [encomendas] = await db.promise().query(`
      SELECT p.id, p.numero_pedido, p.nome_envio AS cliente_nome, p.total, p.subtotal, p.iva,
             p.estado, p.data_criacao, u.nome AS utilizador_nome, u.email AS utilizador_email
      FROM pedidos p LEFT JOIN utilizadores u ON p.utilizador_id = u.id ORDER BY p.data_criacao DESC
    `);
    res.json(encomendas);
  } catch (err) {
    res.status(500).json({ erro: 'Erro ao buscar encomendas' });
  }
});

app.get('/api/admin/encomendas/:id', requireAdmin, async (req, res) => {
  const { id } = req.params;
  try {
    const [[pedido]] = await db.promise().query('SELECT * FROM pedidos WHERE id = ?', [id]);
    if (!pedido) return res.status(404).json({ erro: 'Encomenda não encontrada' });
    const [items] = await db.promise().query(`
      SELECT pi.*, p.nome, p.imagem FROM itens_pedido pi LEFT JOIN produtos p ON pi.produto_id = p.id WHERE pi.pedido_id = ?
    `, [id]);
    pedido.items = items;
    res.json(pedido);
  } catch (err) {
    res.status(500).json({ erro: 'Erro ao buscar encomenda' });
  }
});

app.put('/api/admin/encomendas/:id/estado', requireAdmin, async (req, res) => {
  const { id } = req.params;
  const { estado } = req.body;
  const estadosValidos = ['pendente', 'processando', 'enviado', 'entregue', 'cancelado'];
  if (!estadosValidos.includes(estado)) return res.status(400).json({ erro: 'Estado inválido' });
  try {
    await db.promise().query('UPDATE pedidos SET estado = ? WHERE id = ?', [estado, id]);
    res.json({ sucesso: true, mensagem: 'Estado atualizado' });
  } catch (err) {
    res.status(500).json({ erro: 'Erro ao atualizar estado' });
  }
});

app.get('/api/admin/utilizadores', requireAdmin, async (req, res) => {
  try {
    const [users] = await db.promise().query('SELECT id, nome, email, telefone, role, data_registo FROM utilizadores ORDER BY data_registo DESC');
    res.json(users);
  } catch (err) {
    res.status(500).json({ erro: 'Erro ao buscar utilizadores' });
  }
});

app.put('/api/admin/utilizadores/:id/role', requireAdmin, async (req, res) => {
  const { id } = req.params;
  const { role } = req.body;
  const rolesValidos = ['user', 'admin'];
  if (!rolesValidos.includes(role)) return res.status(400).json({ erro: 'Role inválido' });
  try {
    await db.promise().query('UPDATE utilizadores SET role = ? WHERE id = ?', [role, id]);
    res.json({ sucesso: true, mensagem: 'Role atualizado' });
  } catch (err) {
    res.status(500).json({ erro: 'Erro ao atualizar role' });
  }
});

app.delete('/api/admin/utilizadores/:id', requireAdmin, async (req, res) => {
  const { id } = req.params;
  if (parseInt(id) === req.session.utilizador.id) return res.status(400).json({ erro: 'Não podes remover a tua própria conta' });
  try {
    const [result] = await db.promise().query('DELETE FROM utilizadores WHERE id = ?', [id]);
    if (result.affectedRows === 0) return res.status(404).json({ erro: 'Utilizador não encontrado' });
    res.json({ sucesso: true, mensagem: 'Utilizador removido' });
  } catch (err) {
    res.status(500).json({ erro: 'Erro ao remover utilizador' });
  }
});

app.get('/api/admin/stats', requireAdmin, async (req, res) => {
  try {
    const [[{ total_produtos }]] = await db.promise().query('SELECT COUNT(*) AS total_produtos FROM produtos WHERE ativo = 1');
    const [[{ total_utilizadores }]] = await db.promise().query('SELECT COUNT(*) AS total_utilizadores FROM utilizadores');
    const [[{ total_encomendas }]] = await db.promise().query('SELECT COUNT(*) AS total_encomendas FROM pedidos');
    const [[{ total_promocoes }]] = await db.promise().query('SELECT COUNT(*) AS total_promocoes FROM produtos WHERE em_promocao = 1 AND ativo = 1');
    const [stock_baixo] = await db.promise().query('SELECT id, nome, stock FROM produtos WHERE stock <= 10 AND ativo = 1 ORDER BY stock ASC LIMIT 5');
    const [ultimas_encomendas] = await db.promise().query(`
      SELECT p.id, p.numero_pedido, p.nome_envio AS cliente_nome, p.estado, p.total, p.data_criacao
      FROM pedidos p ORDER BY p.data_criacao DESC LIMIT 5
    `);
    res.json({ total_produtos, total_utilizadores, total_encomendas, total_promocoes, stock_baixo, ultimas_encomendas });
  } catch (err) {
    res.status(500).json({ erro: 'Erro ao buscar estatísticas' });
  }
});

app.get('/api/admin/contactos', requireAdmin, async (req, res) => {
  try {
    const [rows] = await db.promise().query(
      `SELECT * FROM contactos ORDER BY data_criacao DESC`
    );
    res.json(rows);
  } catch (err) {
    res.status(500).json({ erro: 'Erro ao buscar mensagens' });
  }
});

app.patch('/api/admin/contactos/:id/estado', requireAdmin, async (req, res) => {
  const { id } = req.params;
  const { estado } = req.body;
  const dataResposta = estado === 'Respondido' ? new Date() : null;
  try {
    await db.promise().query(
      `UPDATE contactos SET estado = ?, data_resposta = COALESCE(?, data_resposta) WHERE id = ?`,
      [estado, dataResposta, id]
    );
    res.json({ sucesso: true });
  } catch (err) {
    res.status(500).json({ erro: 'Erro ao atualizar estado' });
  }
});

app.delete('/api/admin/contactos/:id', requireAdmin, async (req, res) => {
  const { id } = req.params;
  try {
    await db.promise().query(`DELETE FROM contactos WHERE id = ?`, [id]);
    res.json({ sucesso: true });
  } catch (err) {
    res.status(500).json({ erro: 'Erro ao eliminar mensagem' });
  }
});

app.get('/admin', (req, res) => {
  res.redirect('/admin/dashboard.html');
});

app.listen(PORT, () => {
  console.log(`🚀 Servidor rodando em http://localhost:${PORT}`);
});