--
-- PostgreSQL database dump
--

\restrict YsJac8VkXJLc221Ulq2NEaqJFYOOxEHu0YgK0H4B8Re4gE9GiVVTIsKh4JSJ61C

-- Dumped from database version 18.6
-- Dumped by pg_dump version 18.6

-- Started on 2026-10-19 18:30:51

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 6 (class 2615 OID 16784)
-- Name: sc; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA sc;


ALTER SCHEMA sc OWNER TO postgres;

--
-- TOC entry 255 (class 1255 OID 17185)
-- Name: atualizar_data_modificacao(); Type: FUNCTION; Schema: sc; Owner: postgres
--

CREATE FUNCTION sc.atualizar_data_modificacao() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.atualizado_em := NOW();
    RETURN NEW;
END;
$$;


ALTER FUNCTION sc.atualizar_data_modificacao() OWNER TO postgres;

--
-- TOC entry 256 (class 1255 OID 17181)
-- Name: registrar_auditoria(); Type: FUNCTION; Schema: sc; Owner: postgres
--

CREATE FUNCTION sc.registrar_auditoria() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_id TEXT;
    v_detalhes JSONB;
BEGIN
    IF TG_OP = 'DELETE' THEN
        v_id := to_jsonb(OLD)->>'id';
        v_detalhes := jsonb_build_object('antes', to_jsonb(OLD));
    ELSIF TG_OP = 'UPDATE' THEN
        v_id := to_jsonb(NEW)->>'id';
        v_detalhes := jsonb_build_object(
            'antes', to_jsonb(OLD),
            'depois', to_jsonb(NEW)
        );
    ELSE
        v_id := to_jsonb(NEW)->>'id';
        v_detalhes := jsonb_build_object('depois', to_jsonb(NEW));
    END IF;

    INSERT INTO sc.auditoria (
        tabela, operacao, registro_id, detalhes
    )
    VALUES (TG_TABLE_SCHEMA || '.' || TG_TABLE_NAME,
            TG_OP, v_id, v_detalhes);

    IF TG_OP = 'DELETE' THEN
        RETURN OLD;
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION sc.registrar_auditoria() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 251 (class 1259 OID 17167)
-- Name: auditoria; Type: TABLE; Schema: sc; Owner: postgres
--

CREATE TABLE sc.auditoria (
    id bigint NOT NULL,
    tabela character varying(100) NOT NULL,
    operacao character varying(10) NOT NULL,
    registro_id text,
    usuario_banco text DEFAULT CURRENT_USER NOT NULL,
    detalhes jsonb,
    registrado_em timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE sc.auditoria OWNER TO postgres;

--
-- TOC entry 250 (class 1259 OID 17166)
-- Name: auditoria_id_seq; Type: SEQUENCE; Schema: sc; Owner: postgres
--

ALTER TABLE sc.auditoria ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME sc.auditoria_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 229 (class 1259 OID 16874)
-- Name: categorias; Type: TABLE; Schema: sc; Owner: postgres
--

CREATE TABLE sc.categorias (
    id bigint NOT NULL,
    nome character varying(100) NOT NULL,
    descricao text,
    ativa boolean DEFAULT true NOT NULL
);


ALTER TABLE sc.categorias OWNER TO postgres;

--
-- TOC entry 228 (class 1259 OID 16873)
-- Name: categorias_id_seq; Type: SEQUENCE; Schema: sc; Owner: postgres
--

ALTER TABLE sc.categorias ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME sc.categorias_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 223 (class 1259 OID 16810)
-- Name: clientes; Type: TABLE; Schema: sc; Owner: postgres
--

CREATE TABLE sc.clientes (
    id bigint NOT NULL,
    usuario_id bigint,
    nome character varying(150) NOT NULL,
    cpf character varying(14),
    telefone character varying(25),
    email character varying(254),
    criado_em timestamp with time zone DEFAULT now() NOT NULL,
    ativo boolean DEFAULT true NOT NULL
);


ALTER TABLE sc.clientes OWNER TO postgres;

--
-- TOC entry 222 (class 1259 OID 16809)
-- Name: clientes_id_seq; Type: SEQUENCE; Schema: sc; Owner: postgres
--

ALTER TABLE sc.clientes ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME sc.clientes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 225 (class 1259 OID 16831)
-- Name: enderecos; Type: TABLE; Schema: sc; Owner: postgres
--

CREATE TABLE sc.enderecos (
    id bigint NOT NULL,
    cliente_id bigint NOT NULL,
    identificacao character varying(50) DEFAULT 'Principal'::character varying NOT NULL,
    destinatario character varying(150) NOT NULL,
    cep character varying(10) NOT NULL,
    logradouro character varying(180) NOT NULL,
    numero character varying(20) NOT NULL,
    complemento character varying(100),
    bairro character varying(100) NOT NULL,
    cidade character varying(100) NOT NULL,
    estado character(2) NOT NULL,
    principal boolean DEFAULT false NOT NULL,
    criado_em timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE sc.enderecos OWNER TO postgres;

--
-- TOC entry 224 (class 1259 OID 16830)
-- Name: enderecos_id_seq; Type: SEQUENCE; Schema: sc; Owner: postgres
--

ALTER TABLE sc.enderecos ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME sc.enderecos_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 245 (class 1259 OID 17109)
-- Name: entregas; Type: TABLE; Schema: sc; Owner: postgres
--

CREATE TABLE sc.entregas (
    id bigint NOT NULL,
    pedido_id bigint NOT NULL,
    transportadora character varying(120),
    codigo_rastreio character varying(120),
    status character varying(20) DEFAULT 'PENDENTE'::character varying NOT NULL,
    previsao_entrega timestamp with time zone,
    entregue_em timestamp with time zone,
    criado_em timestamp with time zone DEFAULT now() NOT NULL,
    atualizado_em timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT entregas_status_check CHECK (((status)::text = ANY ((ARRAY['PENDENTE'::character varying, 'PREPARANDO'::character varying, 'EM_TRANSITO'::character varying, 'ENTREGUE'::character varying, 'CANCELADA'::character varying])::text[])))
);


ALTER TABLE sc.entregas OWNER TO postgres;

--
-- TOC entry 244 (class 1259 OID 17108)
-- Name: entregas_id_seq; Type: SEQUENCE; Schema: sc; Owner: postgres
--

ALTER TABLE sc.entregas ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME sc.entregas_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 233 (class 1259 OID 16938)
-- Name: estoque; Type: TABLE; Schema: sc; Owner: postgres
--

CREATE TABLE sc.estoque (
    produto_id bigint NOT NULL,
    quantidade integer DEFAULT 0 NOT NULL,
    estoque_minimo integer DEFAULT 0 NOT NULL,
    atualizado_em timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT estoque_estoque_minimo_check CHECK ((estoque_minimo >= 0)),
    CONSTRAINT estoque_quantidade_check CHECK ((quantidade >= 0))
);


ALTER TABLE sc.estoque OWNER TO postgres;

--
-- TOC entry 227 (class 1259 OID 16860)
-- Name: fornecedores; Type: TABLE; Schema: sc; Owner: postgres
--

CREATE TABLE sc.fornecedores (
    id bigint NOT NULL,
    nome character varying(150) NOT NULL,
    documento character varying(18),
    email character varying(254),
    telefone character varying(25),
    ativo boolean DEFAULT true NOT NULL,
    criado_em timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE sc.fornecedores OWNER TO postgres;

--
-- TOC entry 226 (class 1259 OID 16859)
-- Name: fornecedores_id_seq; Type: SEQUENCE; Schema: sc; Owner: postgres
--

ALTER TABLE sc.fornecedores ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME sc.fornecedores_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 247 (class 1259 OID 17131)
-- Name: historico_entregas; Type: TABLE; Schema: sc; Owner: postgres
--

CREATE TABLE sc.historico_entregas (
    id bigint NOT NULL,
    entrega_id bigint NOT NULL,
    status_anterior character varying(20),
    status_novo character varying(20) NOT NULL,
    observacao text,
    registrado_em timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE sc.historico_entregas OWNER TO postgres;

--
-- TOC entry 246 (class 1259 OID 17130)
-- Name: historico_entregas_id_seq; Type: SEQUENCE; Schema: sc; Owner: postgres
--

ALTER TABLE sc.historico_entregas ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME sc.historico_entregas_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 249 (class 1259 OID 17149)
-- Name: historico_pedidos; Type: TABLE; Schema: sc; Owner: postgres
--

CREATE TABLE sc.historico_pedidos (
    id bigint NOT NULL,
    pedido_id bigint NOT NULL,
    status_anterior character varying(20),
    status_novo character varying(20) NOT NULL,
    observacao text,
    registrado_em timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE sc.historico_pedidos OWNER TO postgres;

--
-- TOC entry 248 (class 1259 OID 17148)
-- Name: historico_pedidos_id_seq; Type: SEQUENCE; Schema: sc; Owner: postgres
--

ALTER TABLE sc.historico_pedidos ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME sc.historico_pedidos_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 239 (class 1259 OID 17027)
-- Name: itens_pedido; Type: TABLE; Schema: sc; Owner: postgres
--

CREATE TABLE sc.itens_pedido (
    id bigint NOT NULL,
    pedido_id bigint NOT NULL,
    produto_id bigint NOT NULL,
    quantidade integer NOT NULL,
    preco_unitario numeric(12,2) NOT NULL,
    desconto numeric(12,2) DEFAULT 0 NOT NULL,
    total_item numeric(12,2) GENERATED ALWAYS AS ((((quantidade)::numeric * preco_unitario) - desconto)) STORED,
    criado_em timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT ck_sc_desconto_item CHECK ((desconto <= ((quantidade)::numeric * preco_unitario))),
    CONSTRAINT itens_pedido_desconto_check CHECK ((desconto >= (0)::numeric)),
    CONSTRAINT itens_pedido_preco_unitario_check CHECK ((preco_unitario >= (0)::numeric)),
    CONSTRAINT itens_pedido_quantidade_check CHECK ((quantidade > 0))
);


ALTER TABLE sc.itens_pedido OWNER TO postgres;

--
-- TOC entry 238 (class 1259 OID 17026)
-- Name: itens_pedido_id_seq; Type: SEQUENCE; Schema: sc; Owner: postgres
--

ALTER TABLE sc.itens_pedido ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME sc.itens_pedido_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 235 (class 1259 OID 16958)
-- Name: movimentos_estoque; Type: TABLE; Schema: sc; Owner: postgres
--

CREATE TABLE sc.movimentos_estoque (
    id bigint NOT NULL,
    produto_id bigint NOT NULL,
    tipo character varying(20) NOT NULL,
    quantidade integer NOT NULL,
    quantidade_anterior integer NOT NULL,
    quantidade_posterior integer NOT NULL,
    motivo text NOT NULL,
    referencia character varying(100),
    usuario_id bigint,
    criado_em timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT movimentos_estoque_quantidade_anterior_check CHECK ((quantidade_anterior >= 0)),
    CONSTRAINT movimentos_estoque_quantidade_check CHECK ((quantidade > 0)),
    CONSTRAINT movimentos_estoque_quantidade_posterior_check CHECK ((quantidade_posterior >= 0)),
    CONSTRAINT movimentos_estoque_tipo_check CHECK (((tipo)::text = ANY ((ARRAY['ENTRADA'::character varying, 'SAIDA'::character varying, 'AJUSTE'::character varying, 'RESERVA'::character varying, 'CANCELAMENTO'::character varying])::text[])))
);


ALTER TABLE sc.movimentos_estoque OWNER TO postgres;

--
-- TOC entry 234 (class 1259 OID 16957)
-- Name: movimentos_estoque_id_seq; Type: SEQUENCE; Schema: sc; Owner: postgres
--

ALTER TABLE sc.movimentos_estoque ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME sc.movimentos_estoque_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 241 (class 1259 OID 17057)
-- Name: pagamentos; Type: TABLE; Schema: sc; Owner: postgres
--

CREATE TABLE sc.pagamentos (
    id bigint NOT NULL,
    pedido_id bigint NOT NULL,
    referencia_externa character varying(150),
    idempotencia_key character varying(150),
    metodo character varying(25) NOT NULL,
    status character varying(20) DEFAULT 'PENDENTE'::character varying NOT NULL,
    valor numeric(12,2) NOT NULL,
    criado_em timestamp with time zone DEFAULT now() NOT NULL,
    atualizado_em timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT pagamentos_metodo_check CHECK (((metodo)::text = ANY ((ARRAY['PIX'::character varying, 'CARTAO'::character varying, 'BOLETO'::character varying, 'DINHEIRO'::character varying, 'OUTRO'::character varying])::text[]))),
    CONSTRAINT pagamentos_status_check CHECK (((status)::text = ANY ((ARRAY['PENDENTE'::character varying, 'APROVADO'::character varying, 'RECUSADO'::character varying, 'ESTORNADO'::character varying])::text[]))),
    CONSTRAINT pagamentos_valor_check CHECK ((valor > (0)::numeric))
);


ALTER TABLE sc.pagamentos OWNER TO postgres;

--
-- TOC entry 240 (class 1259 OID 17056)
-- Name: pagamentos_id_seq; Type: SEQUENCE; Schema: sc; Owner: postgres
--

ALTER TABLE sc.pagamentos ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME sc.pagamentos_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 237 (class 1259 OID 16989)
-- Name: pedidos; Type: TABLE; Schema: sc; Owner: postgres
--

CREATE TABLE sc.pedidos (
    id bigint NOT NULL,
    numero character varying(30) NOT NULL,
    cliente_id bigint NOT NULL,
    status character varying(20) DEFAULT 'RASCUNHO'::character varying NOT NULL,
    subtotal numeric(12,2) DEFAULT 0 NOT NULL,
    frete numeric(12,2) DEFAULT 0 NOT NULL,
    desconto numeric(12,2) DEFAULT 0 NOT NULL,
    total numeric(12,2) DEFAULT 0 NOT NULL,
    endereco_entrega jsonb NOT NULL,
    observacoes text,
    criado_em timestamp with time zone DEFAULT now() NOT NULL,
    atualizado_em timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT pedidos_desconto_check CHECK ((desconto >= (0)::numeric)),
    CONSTRAINT pedidos_frete_check CHECK ((frete >= (0)::numeric)),
    CONSTRAINT pedidos_status_check CHECK (((status)::text = ANY ((ARRAY['RASCUNHO'::character varying, 'PENDENTE'::character varying, 'PAGO'::character varying, 'SEPARANDO'::character varying, 'ENVIADO'::character varying, 'ENTREGUE'::character varying, 'CANCELADO'::character varying])::text[]))),
    CONSTRAINT pedidos_subtotal_check CHECK ((subtotal >= (0)::numeric)),
    CONSTRAINT pedidos_total_check CHECK ((total >= (0)::numeric))
);


ALTER TABLE sc.pedidos OWNER TO postgres;

--
-- TOC entry 236 (class 1259 OID 16988)
-- Name: pedidos_id_seq; Type: SEQUENCE; Schema: sc; Owner: postgres
--

ALTER TABLE sc.pedidos ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME sc.pedidos_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 231 (class 1259 OID 16888)
-- Name: produtos; Type: TABLE; Schema: sc; Owner: postgres
--

CREATE TABLE sc.produtos (
    id bigint NOT NULL,
    categoria_id bigint,
    nome character varying(160) NOT NULL,
    descricao text,
    sku character varying(60) NOT NULL,
    codigo_barras character varying(50),
    preco numeric(12,2) NOT NULL,
    custo numeric(12,2) DEFAULT 0 NOT NULL,
    ativo boolean DEFAULT true NOT NULL,
    criado_em timestamp with time zone DEFAULT now() NOT NULL,
    atualizado_em timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT produtos_custo_check CHECK ((custo >= (0)::numeric)),
    CONSTRAINT produtos_preco_check CHECK ((preco >= (0)::numeric))
);


ALTER TABLE sc.produtos OWNER TO postgres;

--
-- TOC entry 232 (class 1259 OID 16918)
-- Name: produtos_fornecedores; Type: TABLE; Schema: sc; Owner: postgres
--

CREATE TABLE sc.produtos_fornecedores (
    produto_id bigint NOT NULL,
    fornecedor_id bigint NOT NULL,
    codigo_no_fornecedor character varying(80),
    custo_atual numeric(12,2) DEFAULT 0 NOT NULL,
    CONSTRAINT produtos_fornecedores_custo_atual_check CHECK ((custo_atual >= (0)::numeric))
);


ALTER TABLE sc.produtos_fornecedores OWNER TO postgres;

--
-- TOC entry 230 (class 1259 OID 16887)
-- Name: produtos_id_seq; Type: SEQUENCE; Schema: sc; Owner: postgres
--

ALTER TABLE sc.produtos ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME sc.produtos_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 221 (class 1259 OID 16786)
-- Name: usuarios; Type: TABLE; Schema: sc; Owner: postgres
--

CREATE TABLE sc.usuarios (
    id bigint NOT NULL,
    nome character varying(120) NOT NULL,
    email character varying(254) NOT NULL,
    senha_hash text NOT NULL,
    perfil character varying(20) DEFAULT 'CLIENTE'::character varying NOT NULL,
    ativo boolean DEFAULT true NOT NULL,
    criado_em timestamp with time zone DEFAULT now() NOT NULL,
    atualizado_em timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT ck_sc_usuario_email CHECK ((POSITION(('@'::text) IN (email)) > 1)),
    CONSTRAINT usuarios_perfil_check CHECK (((perfil)::text = ANY ((ARRAY['ADMIN'::character varying, 'FUNCIONARIO'::character varying, 'CLIENTE'::character varying])::text[])))
);


ALTER TABLE sc.usuarios OWNER TO postgres;

--
-- TOC entry 220 (class 1259 OID 16785)
-- Name: usuarios_id_seq; Type: SEQUENCE; Schema: sc; Owner: postgres
--

ALTER TABLE sc.usuarios ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME sc.usuarios_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 243 (class 1259 OID 17085)
-- Name: vendas; Type: TABLE; Schema: sc; Owner: postgres
--

CREATE TABLE sc.vendas (
    id bigint NOT NULL,
    pedido_id bigint NOT NULL,
    pagamento_id bigint,
    valor_total numeric(12,2) NOT NULL,
    confirmada_em timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT vendas_valor_total_check CHECK ((valor_total >= (0)::numeric))
);


ALTER TABLE sc.vendas OWNER TO postgres;

--
-- TOC entry 242 (class 1259 OID 17084)
-- Name: vendas_id_seq; Type: SEQUENCE; Schema: sc; Owner: postgres
--

ALTER TABLE sc.vendas ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME sc.vendas_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 252 (class 1259 OID 17201)
-- Name: vw_estoque_baixo; Type: VIEW; Schema: sc; Owner: postgres
--

CREATE VIEW sc.vw_estoque_baixo AS
 SELECT p.id AS produto_id,
    p.sku,
    p.nome AS produto,
    e.quantidade,
    e.estoque_minimo
   FROM (sc.produtos p
     JOIN sc.estoque e ON ((e.produto_id = p.id)))
  WHERE ((p.ativo = true) AND (e.quantidade <= e.estoque_minimo));


ALTER VIEW sc.vw_estoque_baixo OWNER TO postgres;

--
-- TOC entry 254 (class 1259 OID 17209)
-- Name: vw_produtos_mais_vendidos; Type: VIEW; Schema: sc; Owner: postgres
--

CREATE VIEW sc.vw_produtos_mais_vendidos AS
 SELECT p.id AS produto_id,
    p.sku,
    p.nome AS produto,
    sum(ip.quantidade) AS unidades_vendidas,
    sum(ip.total_item) AS valor_vendido
   FROM ((sc.itens_pedido ip
     JOIN sc.pedidos pe ON ((pe.id = ip.pedido_id)))
     JOIN sc.produtos p ON ((p.id = ip.produto_id)))
  WHERE ((pe.status)::text = ANY ((ARRAY['PAGO'::character varying, 'SEPARANDO'::character varying, 'ENVIADO'::character varying, 'ENTREGUE'::character varying])::text[]))
  GROUP BY p.id, p.sku, p.nome;


ALTER VIEW sc.vw_produtos_mais_vendidos OWNER TO postgres;

--
-- TOC entry 253 (class 1259 OID 17205)
-- Name: vw_vendas_diarias; Type: VIEW; Schema: sc; Owner: postgres
--

CREATE VIEW sc.vw_vendas_diarias AS
 SELECT date(confirmada_em) AS dia,
    count(*) AS quantidade_vendas,
    sum(valor_total) AS faturamento
   FROM sc.vendas
  GROUP BY (date(confirmada_em));


ALTER VIEW sc.vw_vendas_diarias OWNER TO postgres;

--
-- TOC entry 5291 (class 0 OID 17167)
-- Dependencies: 251
-- Data for Name: auditoria; Type: TABLE DATA; Schema: sc; Owner: postgres
--

COPY sc.auditoria (id, tabela, operacao, registro_id, usuario_banco, detalhes, registrado_em) FROM stdin;
1	sc.produtos	INSERT	1	postgres	{"depois": {"id": 1, "sku": "SUP-001", "nome": "Arroz 5 kg", "ativo": true, "custo": 18.00, "preco": 25.90, "criado_em": "2026-10-19T17:42:58.851264-03:00", "descricao": "Arroz tipo 1 pacote de 5 kg", "categoria_id": null, "atualizado_em": "2026-10-19T17:42:58.851264-03:00", "codigo_barras": null}}	2026-10-19 17:42:58.851264-03
2	sc.estoque	INSERT	\N	postgres	{"depois": {"produto_id": 1, "quantidade": 20, "atualizado_em": "2026-10-19T17:45:20.072523-03:00", "estoque_minimo": 5}}	2026-10-19 17:45:20.072523-03
3	sc.pedidos	INSERT	5	postgres	{"depois": {"id": 5, "frete": 0.00, "total": 25.90, "numero": "PED-0001", "status": "PENDENTE", "desconto": 0.00, "subtotal": 25.90, "criado_em": "2026-10-19T17:53:32.979297-03:00", "cliente_id": 1, "observacoes": null, "atualizado_em": "2026-10-19T17:53:32.979297-03:00", "endereco_entrega": {"UF": "DF", "CEP": "70000000", "rua": "Rua Exemplo", "cidade": "Brasilia", "numero": "100"}}}	2026-10-19 17:53:32.979297-03
\.


--
-- TOC entry 5269 (class 0 OID 16874)
-- Dependencies: 229
-- Data for Name: categorias; Type: TABLE DATA; Schema: sc; Owner: postgres
--

COPY sc.categorias (id, nome, descricao, ativa) FROM stdin;
\.


--
-- TOC entry 5263 (class 0 OID 16810)
-- Dependencies: 223
-- Data for Name: clientes; Type: TABLE DATA; Schema: sc; Owner: postgres
--

COPY sc.clientes (id, usuario_id, nome, cpf, telefone, email, criado_em, ativo) FROM stdin;
1	1	Cliente Teste	\N	\N	cliente.teste@supercompra.local	2026-10-19 17:50:19.755323-03	t
\.


--
-- TOC entry 5265 (class 0 OID 16831)
-- Dependencies: 225
-- Data for Name: enderecos; Type: TABLE DATA; Schema: sc; Owner: postgres
--

COPY sc.enderecos (id, cliente_id, identificacao, destinatario, cep, logradouro, numero, complemento, bairro, cidade, estado, principal, criado_em) FROM stdin;
\.


--
-- TOC entry 5285 (class 0 OID 17109)
-- Dependencies: 245
-- Data for Name: entregas; Type: TABLE DATA; Schema: sc; Owner: postgres
--

COPY sc.entregas (id, pedido_id, transportadora, codigo_rastreio, status, previsao_entrega, entregue_em, criado_em, atualizado_em) FROM stdin;
\.


--
-- TOC entry 5273 (class 0 OID 16938)
-- Dependencies: 233
-- Data for Name: estoque; Type: TABLE DATA; Schema: sc; Owner: postgres
--

COPY sc.estoque (produto_id, quantidade, estoque_minimo, atualizado_em) FROM stdin;
1	20	5	2026-10-19 17:45:20.072523-03
\.


--
-- TOC entry 5267 (class 0 OID 16860)
-- Dependencies: 227
-- Data for Name: fornecedores; Type: TABLE DATA; Schema: sc; Owner: postgres
--

COPY sc.fornecedores (id, nome, documento, email, telefone, ativo, criado_em) FROM stdin;
\.


--
-- TOC entry 5287 (class 0 OID 17131)
-- Dependencies: 247
-- Data for Name: historico_entregas; Type: TABLE DATA; Schema: sc; Owner: postgres
--

COPY sc.historico_entregas (id, entrega_id, status_anterior, status_novo, observacao, registrado_em) FROM stdin;
\.


--
-- TOC entry 5289 (class 0 OID 17149)
-- Dependencies: 249
-- Data for Name: historico_pedidos; Type: TABLE DATA; Schema: sc; Owner: postgres
--

COPY sc.historico_pedidos (id, pedido_id, status_anterior, status_novo, observacao, registrado_em) FROM stdin;
\.


--
-- TOC entry 5279 (class 0 OID 17027)
-- Dependencies: 239
-- Data for Name: itens_pedido; Type: TABLE DATA; Schema: sc; Owner: postgres
--

COPY sc.itens_pedido (id, pedido_id, produto_id, quantidade, preco_unitario, desconto, criado_em) FROM stdin;
1	5	1	1	25.90	0.00	2026-10-19 17:56:37.002694-03
\.


--
-- TOC entry 5275 (class 0 OID 16958)
-- Dependencies: 235
-- Data for Name: movimentos_estoque; Type: TABLE DATA; Schema: sc; Owner: postgres
--

COPY sc.movimentos_estoque (id, produto_id, tipo, quantidade, quantidade_anterior, quantidade_posterior, motivo, referencia, usuario_id, criado_em) FROM stdin;
\.


--
-- TOC entry 5281 (class 0 OID 17057)
-- Dependencies: 241
-- Data for Name: pagamentos; Type: TABLE DATA; Schema: sc; Owner: postgres
--

COPY sc.pagamentos (id, pedido_id, referencia_externa, idempotencia_key, metodo, status, valor, criado_em, atualizado_em) FROM stdin;
1	5	TESTE-SUPERCOMPRA-001	\N	PIX	PENDENTE	25.90	2026-10-19 18:15:58.840101-03	2026-10-19 18:20:09.297903-03
\.


--
-- TOC entry 5277 (class 0 OID 16989)
-- Dependencies: 237
-- Data for Name: pedidos; Type: TABLE DATA; Schema: sc; Owner: postgres
--

COPY sc.pedidos (id, numero, cliente_id, status, subtotal, frete, desconto, total, endereco_entrega, observacoes, criado_em, atualizado_em) FROM stdin;
5	PED-0001	1	PENDENTE	25.90	0.00	0.00	25.90	{"UF": "DF", "CEP": "70000000", "rua": "Rua Exemplo", "cidade": "Brasilia", "numero": "100"}	\N	2026-10-19 17:53:32.979297-03	2026-10-19 17:53:32.979297-03
\.


--
-- TOC entry 5271 (class 0 OID 16888)
-- Dependencies: 231
-- Data for Name: produtos; Type: TABLE DATA; Schema: sc; Owner: postgres
--

COPY sc.produtos (id, categoria_id, nome, descricao, sku, codigo_barras, preco, custo, ativo, criado_em, atualizado_em) FROM stdin;
1	\N	Arroz 5 kg	Arroz tipo 1 pacote de 5 kg	SUP-001	\N	25.90	18.00	t	2026-10-19 17:42:58.851264-03	2026-10-19 17:42:58.851264-03
\.


--
-- TOC entry 5272 (class 0 OID 16918)
-- Dependencies: 232
-- Data for Name: produtos_fornecedores; Type: TABLE DATA; Schema: sc; Owner: postgres
--

COPY sc.produtos_fornecedores (produto_id, fornecedor_id, codigo_no_fornecedor, custo_atual) FROM stdin;
\.


--
-- TOC entry 5261 (class 0 OID 16786)
-- Dependencies: 221
-- Data for Name: usuarios; Type: TABLE DATA; Schema: sc; Owner: postgres
--

COPY sc.usuarios (id, nome, email, senha_hash, perfil, ativo, criado_em, atualizado_em) FROM stdin;
1	Cliente Teste	cliente.teste@supercompra.local	HASH_DE_TESTE_NAO_USAR_EM_PRODUCAO	CLIENTE	t	2026-10-19 17:50:01.802921-03	2026-10-19 17:50:01.802921-03
\.


--
-- TOC entry 5283 (class 0 OID 17085)
-- Dependencies: 243
-- Data for Name: vendas; Type: TABLE DATA; Schema: sc; Owner: postgres
--

COPY sc.vendas (id, pedido_id, pagamento_id, valor_total, confirmada_em) FROM stdin;
\.


--
-- TOC entry 5297 (class 0 OID 0)
-- Dependencies: 250
-- Name: auditoria_id_seq; Type: SEQUENCE SET; Schema: sc; Owner: postgres
--

SELECT pg_catalog.setval('sc.auditoria_id_seq', 3, true);


--
-- TOC entry 5298 (class 0 OID 0)
-- Dependencies: 228
-- Name: categorias_id_seq; Type: SEQUENCE SET; Schema: sc; Owner: postgres
--

SELECT pg_catalog.setval('sc.categorias_id_seq', 1, false);


--
-- TOC entry 5299 (class 0 OID 0)
-- Dependencies: 222
-- Name: clientes_id_seq; Type: SEQUENCE SET; Schema: sc; Owner: postgres
--

SELECT pg_catalog.setval('sc.clientes_id_seq', 1, true);


--
-- TOC entry 5300 (class 0 OID 0)
-- Dependencies: 224
-- Name: enderecos_id_seq; Type: SEQUENCE SET; Schema: sc; Owner: postgres
--

SELECT pg_catalog.setval('sc.enderecos_id_seq', 1, false);


--
-- TOC entry 5301 (class 0 OID 0)
-- Dependencies: 244
-- Name: entregas_id_seq; Type: SEQUENCE SET; Schema: sc; Owner: postgres
--

SELECT pg_catalog.setval('sc.entregas_id_seq', 1, false);


--
-- TOC entry 5302 (class 0 OID 0)
-- Dependencies: 226
-- Name: fornecedores_id_seq; Type: SEQUENCE SET; Schema: sc; Owner: postgres
--

SELECT pg_catalog.setval('sc.fornecedores_id_seq', 1, false);


--
-- TOC entry 5303 (class 0 OID 0)
-- Dependencies: 246
-- Name: historico_entregas_id_seq; Type: SEQUENCE SET; Schema: sc; Owner: postgres
--

SELECT pg_catalog.setval('sc.historico_entregas_id_seq', 1, false);


--
-- TOC entry 5304 (class 0 OID 0)
-- Dependencies: 248
-- Name: historico_pedidos_id_seq; Type: SEQUENCE SET; Schema: sc; Owner: postgres
--

SELECT pg_catalog.setval('sc.historico_pedidos_id_seq', 1, false);


--
-- TOC entry 5305 (class 0 OID 0)
-- Dependencies: 238
-- Name: itens_pedido_id_seq; Type: SEQUENCE SET; Schema: sc; Owner: postgres
--

SELECT pg_catalog.setval('sc.itens_pedido_id_seq', 1, true);


--
-- TOC entry 5306 (class 0 OID 0)
-- Dependencies: 234
-- Name: movimentos_estoque_id_seq; Type: SEQUENCE SET; Schema: sc; Owner: postgres
--

SELECT pg_catalog.setval('sc.movimentos_estoque_id_seq', 1, false);


--
-- TOC entry 5307 (class 0 OID 0)
-- Dependencies: 240
-- Name: pagamentos_id_seq; Type: SEQUENCE SET; Schema: sc; Owner: postgres
--

SELECT pg_catalog.setval('sc.pagamentos_id_seq', 1, true);


--
-- TOC entry 5308 (class 0 OID 0)
-- Dependencies: 236
-- Name: pedidos_id_seq; Type: SEQUENCE SET; Schema: sc; Owner: postgres
--

SELECT pg_catalog.setval('sc.pedidos_id_seq', 5, true);


--
-- TOC entry 5309 (class 0 OID 0)
-- Dependencies: 230
-- Name: produtos_id_seq; Type: SEQUENCE SET; Schema: sc; Owner: postgres
--

SELECT pg_catalog.setval('sc.produtos_id_seq', 1, true);


--
-- TOC entry 5310 (class 0 OID 0)
-- Dependencies: 220
-- Name: usuarios_id_seq; Type: SEQUENCE SET; Schema: sc; Owner: postgres
--

SELECT pg_catalog.setval('sc.usuarios_id_seq', 1, true);


--
-- TOC entry 5311 (class 0 OID 0)
-- Dependencies: 242
-- Name: vendas_id_seq; Type: SEQUENCE SET; Schema: sc; Owner: postgres
--

SELECT pg_catalog.setval('sc.vendas_id_seq', 1, false);


--
-- TOC entry 5083 (class 2606 OID 17180)
-- Name: auditoria auditoria_pkey; Type: CONSTRAINT; Schema: sc; Owner: postgres
--

ALTER TABLE ONLY sc.auditoria
    ADD CONSTRAINT auditoria_pkey PRIMARY KEY (id);


--
-- TOC entry 5035 (class 2606 OID 16886)
-- Name: categorias categorias_nome_key; Type: CONSTRAINT; Schema: sc; Owner: postgres
--

ALTER TABLE ONLY sc.categorias
    ADD CONSTRAINT categorias_nome_key UNIQUE (nome);


--
-- TOC entry 5037 (class 2606 OID 16884)
-- Name: categorias categorias_pkey; Type: CONSTRAINT; Schema: sc; Owner: postgres
--

ALTER TABLE ONLY sc.categorias
    ADD CONSTRAINT categorias_pkey PRIMARY KEY (id);


--
-- TOC entry 5021 (class 2606 OID 16824)
-- Name: clientes clientes_cpf_key; Type: CONSTRAINT; Schema: sc; Owner: postgres
--

ALTER TABLE ONLY sc.clientes
    ADD CONSTRAINT clientes_cpf_key UNIQUE (cpf);


--
-- TOC entry 5023 (class 2606 OID 16820)
-- Name: clientes clientes_pkey; Type: CONSTRAINT; Schema: sc; Owner: postgres
--

ALTER TABLE ONLY sc.clientes
    ADD CONSTRAINT clientes_pkey PRIMARY KEY (id);


--
-- TOC entry 5025 (class 2606 OID 16822)
-- Name: clientes clientes_usuario_id_key; Type: CONSTRAINT; Schema: sc; Owner: postgres
--

ALTER TABLE ONLY sc.clientes
    ADD CONSTRAINT clientes_usuario_id_key UNIQUE (usuario_id);


--
-- TOC entry 5028 (class 2606 OID 16852)
-- Name: enderecos enderecos_pkey; Type: CONSTRAINT; Schema: sc; Owner: postgres
--

ALTER TABLE ONLY sc.enderecos
    ADD CONSTRAINT enderecos_pkey PRIMARY KEY (id);


--
-- TOC entry 5074 (class 2606 OID 17124)
-- Name: entregas entregas_pedido_id_key; Type: CONSTRAINT; Schema: sc; Owner: postgres
--

ALTER TABLE ONLY sc.entregas
    ADD CONSTRAINT entregas_pedido_id_key UNIQUE (pedido_id);


--
-- TOC entry 5076 (class 2606 OID 17122)
-- Name: entregas entregas_pkey; Type: CONSTRAINT; Schema: sc; Owner: postgres
--

ALTER TABLE ONLY sc.entregas
    ADD CONSTRAINT entregas_pkey PRIMARY KEY (id);


--
-- TOC entry 5049 (class 2606 OID 16951)
-- Name: estoque estoque_pkey; Type: CONSTRAINT; Schema: sc; Owner: postgres
--

ALTER TABLE ONLY sc.estoque
    ADD CONSTRAINT estoque_pkey PRIMARY KEY (produto_id);


--
-- TOC entry 5031 (class 2606 OID 16872)
-- Name: fornecedores fornecedores_documento_key; Type: CONSTRAINT; Schema: sc; Owner: postgres
--

ALTER TABLE ONLY sc.fornecedores
    ADD CONSTRAINT fornecedores_documento_key UNIQUE (documento);


--
-- TOC entry 5033 (class 2606 OID 16870)
-- Name: fornecedores fornecedores_pkey; Type: CONSTRAINT; Schema: sc; Owner: postgres
--

ALTER TABLE ONLY sc.fornecedores
    ADD CONSTRAINT fornecedores_pkey PRIMARY KEY (id);


--
-- TOC entry 5079 (class 2606 OID 17142)
-- Name: historico_entregas historico_entregas_pkey; Type: CONSTRAINT; Schema: sc; Owner: postgres
--

ALTER TABLE ONLY sc.historico_entregas
    ADD CONSTRAINT historico_entregas_pkey PRIMARY KEY (id);


--
-- TOC entry 5081 (class 2606 OID 17160)
-- Name: historico_pedidos historico_pedidos_pkey; Type: CONSTRAINT; Schema: sc; Owner: postgres
--

ALTER TABLE ONLY sc.historico_pedidos
    ADD CONSTRAINT historico_pedidos_pkey PRIMARY KEY (id);


--
-- TOC entry 5061 (class 2606 OID 17045)
-- Name: itens_pedido itens_pedido_pkey; Type: CONSTRAINT; Schema: sc; Owner: postgres
--

ALTER TABLE ONLY sc.itens_pedido
    ADD CONSTRAINT itens_pedido_pkey PRIMARY KEY (id);


--
-- TOC entry 5052 (class 2606 OID 16977)
-- Name: movimentos_estoque movimentos_estoque_pkey; Type: CONSTRAINT; Schema: sc; Owner: postgres
--

ALTER TABLE ONLY sc.movimentos_estoque
    ADD CONSTRAINT movimentos_estoque_pkey PRIMARY KEY (id);


--
-- TOC entry 5064 (class 2606 OID 17078)
-- Name: pagamentos pagamentos_idempotencia_key_key; Type: CONSTRAINT; Schema: sc; Owner: postgres
--

ALTER TABLE ONLY sc.pagamentos
    ADD CONSTRAINT pagamentos_idempotencia_key_key UNIQUE (idempotencia_key);


--
-- TOC entry 5066 (class 2606 OID 17074)
-- Name: pagamentos pagamentos_pkey; Type: CONSTRAINT; Schema: sc; Owner: postgres
--

ALTER TABLE ONLY sc.pagamentos
    ADD CONSTRAINT pagamentos_pkey PRIMARY KEY (id);


--
-- TOC entry 5068 (class 2606 OID 17076)
-- Name: pagamentos pagamentos_referencia_externa_key; Type: CONSTRAINT; Schema: sc; Owner: postgres
--

ALTER TABLE ONLY sc.pagamentos
    ADD CONSTRAINT pagamentos_referencia_externa_key UNIQUE (referencia_externa);


--
-- TOC entry 5056 (class 2606 OID 17020)
-- Name: pedidos pedidos_numero_key; Type: CONSTRAINT; Schema: sc; Owner: postgres
--

ALTER TABLE ONLY sc.pedidos
    ADD CONSTRAINT pedidos_numero_key UNIQUE (numero);


--
-- TOC entry 5058 (class 2606 OID 17018)
-- Name: pedidos pedidos_pkey; Type: CONSTRAINT; Schema: sc; Owner: postgres
--

ALTER TABLE ONLY sc.pedidos
    ADD CONSTRAINT pedidos_pkey PRIMARY KEY (id);


--
-- TOC entry 5041 (class 2606 OID 16912)
-- Name: produtos produtos_codigo_barras_key; Type: CONSTRAINT; Schema: sc; Owner: postgres
--

ALTER TABLE ONLY sc.produtos
    ADD CONSTRAINT produtos_codigo_barras_key UNIQUE (codigo_barras);


--
-- TOC entry 5047 (class 2606 OID 16927)
-- Name: produtos_fornecedores produtos_fornecedores_pkey; Type: CONSTRAINT; Schema: sc; Owner: postgres
--

ALTER TABLE ONLY sc.produtos_fornecedores
    ADD CONSTRAINT produtos_fornecedores_pkey PRIMARY KEY (produto_id, fornecedor_id);


--
-- TOC entry 5043 (class 2606 OID 16908)
-- Name: produtos produtos_pkey; Type: CONSTRAINT; Schema: sc; Owner: postgres
--

ALTER TABLE ONLY sc.produtos
    ADD CONSTRAINT produtos_pkey PRIMARY KEY (id);


--
-- TOC entry 5045 (class 2606 OID 16910)
-- Name: produtos produtos_sku_key; Type: CONSTRAINT; Schema: sc; Owner: postgres
--

ALTER TABLE ONLY sc.produtos
    ADD CONSTRAINT produtos_sku_key UNIQUE (sku);


--
-- TOC entry 5017 (class 2606 OID 16808)
-- Name: usuarios uq_sc_usuario_email; Type: CONSTRAINT; Schema: sc; Owner: postgres
--

ALTER TABLE ONLY sc.usuarios
    ADD CONSTRAINT uq_sc_usuario_email UNIQUE (email);


--
-- TOC entry 5019 (class 2606 OID 16806)
-- Name: usuarios usuarios_pkey; Type: CONSTRAINT; Schema: sc; Owner: postgres
--

ALTER TABLE ONLY sc.usuarios
    ADD CONSTRAINT usuarios_pkey PRIMARY KEY (id);


--
-- TOC entry 5070 (class 2606 OID 17097)
-- Name: vendas vendas_pedido_id_key; Type: CONSTRAINT; Schema: sc; Owner: postgres
--

ALTER TABLE ONLY sc.vendas
    ADD CONSTRAINT vendas_pedido_id_key UNIQUE (pedido_id);


--
-- TOC entry 5072 (class 2606 OID 17095)
-- Name: vendas vendas_pkey; Type: CONSTRAINT; Schema: sc; Owner: postgres
--

ALTER TABLE ONLY sc.vendas
    ADD CONSTRAINT vendas_pkey PRIMARY KEY (id);


--
-- TOC entry 5084 (class 1259 OID 17200)
-- Name: idx_sc_auditoria_data; Type: INDEX; Schema: sc; Owner: postgres
--

CREATE INDEX idx_sc_auditoria_data ON sc.auditoria USING btree (registrado_em DESC);


--
-- TOC entry 5026 (class 1259 OID 17191)
-- Name: idx_sc_clientes_nome; Type: INDEX; Schema: sc; Owner: postgres
--

CREATE INDEX idx_sc_clientes_nome ON sc.clientes USING btree (nome);


--
-- TOC entry 5077 (class 1259 OID 17199)
-- Name: idx_sc_entregas_status; Type: INDEX; Schema: sc; Owner: postgres
--

CREATE INDEX idx_sc_entregas_status ON sc.entregas USING btree (status);


--
-- TOC entry 5059 (class 1259 OID 17197)
-- Name: idx_sc_itens_pedido; Type: INDEX; Schema: sc; Owner: postgres
--

CREATE INDEX idx_sc_itens_pedido ON sc.itens_pedido USING btree (pedido_id);


--
-- TOC entry 5050 (class 1259 OID 17194)
-- Name: idx_sc_movimentos_produto_data; Type: INDEX; Schema: sc; Owner: postgres
--

CREATE INDEX idx_sc_movimentos_produto_data ON sc.movimentos_estoque USING btree (produto_id, criado_em DESC);


--
-- TOC entry 5062 (class 1259 OID 17198)
-- Name: idx_sc_pagamentos_pedido; Type: INDEX; Schema: sc; Owner: postgres
--

CREATE INDEX idx_sc_pagamentos_pedido ON sc.pagamentos USING btree (pedido_id);


--
-- TOC entry 5053 (class 1259 OID 17195)
-- Name: idx_sc_pedidos_cliente_data; Type: INDEX; Schema: sc; Owner: postgres
--

CREATE INDEX idx_sc_pedidos_cliente_data ON sc.pedidos USING btree (cliente_id, criado_em DESC);


--
-- TOC entry 5054 (class 1259 OID 17196)
-- Name: idx_sc_pedidos_status; Type: INDEX; Schema: sc; Owner: postgres
--

CREATE INDEX idx_sc_pedidos_status ON sc.pedidos USING btree (status);


--
-- TOC entry 5038 (class 1259 OID 17193)
-- Name: idx_sc_produtos_ativos; Type: INDEX; Schema: sc; Owner: postgres
--

CREATE INDEX idx_sc_produtos_ativos ON sc.produtos USING btree (nome) WHERE (ativo = true);


--
-- TOC entry 5039 (class 1259 OID 17192)
-- Name: idx_sc_produtos_categoria; Type: INDEX; Schema: sc; Owner: postgres
--

CREATE INDEX idx_sc_produtos_categoria ON sc.produtos USING btree (categoria_id);


--
-- TOC entry 5029 (class 1259 OID 16858)
-- Name: uq_sc_endereco_principal; Type: INDEX; Schema: sc; Owner: postgres
--

CREATE UNIQUE INDEX uq_sc_endereco_principal ON sc.enderecos USING btree (cliente_id) WHERE (principal = true);


--
-- TOC entry 5104 (class 2620 OID 17217)
-- Name: estoque trg_sc_auditoria_estoque; Type: TRIGGER; Schema: sc; Owner: postgres
--

CREATE TRIGGER trg_sc_auditoria_estoque AFTER INSERT OR DELETE OR UPDATE ON sc.estoque FOR EACH ROW EXECUTE FUNCTION sc.registrar_auditoria();


--
-- TOC entry 5106 (class 2620 OID 17216)
-- Name: pedidos trg_sc_auditoria_pedidos; Type: TRIGGER; Schema: sc; Owner: postgres
--

CREATE TRIGGER trg_sc_auditoria_pedidos AFTER INSERT OR DELETE OR UPDATE ON sc.pedidos FOR EACH ROW EXECUTE FUNCTION sc.registrar_auditoria();


--
-- TOC entry 5102 (class 2620 OID 17215)
-- Name: produtos trg_sc_auditoria_produtos; Type: TRIGGER; Schema: sc; Owner: postgres
--

CREATE TRIGGER trg_sc_auditoria_produtos AFTER INSERT OR DELETE OR UPDATE ON sc.produtos FOR EACH ROW EXECUTE FUNCTION sc.registrar_auditoria();


--
-- TOC entry 5109 (class 2620 OID 17222)
-- Name: entregas trg_sc_entregas_data; Type: TRIGGER; Schema: sc; Owner: postgres
--

CREATE TRIGGER trg_sc_entregas_data BEFORE UPDATE ON sc.entregas FOR EACH ROW EXECUTE FUNCTION sc.atualizar_data_modificacao();


--
-- TOC entry 5105 (class 2620 OID 17220)
-- Name: estoque trg_sc_estoque_data; Type: TRIGGER; Schema: sc; Owner: postgres
--

CREATE TRIGGER trg_sc_estoque_data BEFORE UPDATE ON sc.estoque FOR EACH ROW EXECUTE FUNCTION sc.atualizar_data_modificacao();


--
-- TOC entry 5108 (class 2620 OID 17221)
-- Name: pagamentos trg_sc_pagamentos_data; Type: TRIGGER; Schema: sc; Owner: postgres
--

CREATE TRIGGER trg_sc_pagamentos_data BEFORE UPDATE ON sc.pagamentos FOR EACH ROW EXECUTE FUNCTION sc.atualizar_data_modificacao();


--
-- TOC entry 5107 (class 2620 OID 17219)
-- Name: pedidos trg_sc_pedidos_data; Type: TRIGGER; Schema: sc; Owner: postgres
--

CREATE TRIGGER trg_sc_pedidos_data BEFORE UPDATE ON sc.pedidos FOR EACH ROW EXECUTE FUNCTION sc.atualizar_data_modificacao();


--
-- TOC entry 5103 (class 2620 OID 17218)
-- Name: produtos trg_sc_produtos_data; Type: TRIGGER; Schema: sc; Owner: postgres
--

CREATE TRIGGER trg_sc_produtos_data BEFORE UPDATE ON sc.produtos FOR EACH ROW EXECUTE FUNCTION sc.atualizar_data_modificacao();


--
-- TOC entry 5085 (class 2606 OID 16825)
-- Name: clientes clientes_usuario_id_fkey; Type: FK CONSTRAINT; Schema: sc; Owner: postgres
--

ALTER TABLE ONLY sc.clientes
    ADD CONSTRAINT clientes_usuario_id_fkey FOREIGN KEY (usuario_id) REFERENCES sc.usuarios(id);


--
-- TOC entry 5086 (class 2606 OID 16853)
-- Name: enderecos enderecos_cliente_id_fkey; Type: FK CONSTRAINT; Schema: sc; Owner: postgres
--

ALTER TABLE ONLY sc.enderecos
    ADD CONSTRAINT enderecos_cliente_id_fkey FOREIGN KEY (cliente_id) REFERENCES sc.clientes(id);


--
-- TOC entry 5099 (class 2606 OID 17125)
-- Name: entregas entregas_pedido_id_fkey; Type: FK CONSTRAINT; Schema: sc; Owner: postgres
--

ALTER TABLE ONLY sc.entregas
    ADD CONSTRAINT entregas_pedido_id_fkey FOREIGN KEY (pedido_id) REFERENCES sc.pedidos(id);


--
-- TOC entry 5090 (class 2606 OID 16952)
-- Name: estoque estoque_produto_id_fkey; Type: FK CONSTRAINT; Schema: sc; Owner: postgres
--

ALTER TABLE ONLY sc.estoque
    ADD CONSTRAINT estoque_produto_id_fkey FOREIGN KEY (produto_id) REFERENCES sc.produtos(id);


--
-- TOC entry 5100 (class 2606 OID 17143)
-- Name: historico_entregas historico_entregas_entrega_id_fkey; Type: FK CONSTRAINT; Schema: sc; Owner: postgres
--

ALTER TABLE ONLY sc.historico_entregas
    ADD CONSTRAINT historico_entregas_entrega_id_fkey FOREIGN KEY (entrega_id) REFERENCES sc.entregas(id);


--
-- TOC entry 5101 (class 2606 OID 17161)
-- Name: historico_pedidos historico_pedidos_pedido_id_fkey; Type: FK CONSTRAINT; Schema: sc; Owner: postgres
--

ALTER TABLE ONLY sc.historico_pedidos
    ADD CONSTRAINT historico_pedidos_pedido_id_fkey FOREIGN KEY (pedido_id) REFERENCES sc.pedidos(id);


--
-- TOC entry 5094 (class 2606 OID 17046)
-- Name: itens_pedido itens_pedido_pedido_id_fkey; Type: FK CONSTRAINT; Schema: sc; Owner: postgres
--

ALTER TABLE ONLY sc.itens_pedido
    ADD CONSTRAINT itens_pedido_pedido_id_fkey FOREIGN KEY (pedido_id) REFERENCES sc.pedidos(id) ON DELETE RESTRICT;


--
-- TOC entry 5095 (class 2606 OID 17051)
-- Name: itens_pedido itens_pedido_produto_id_fkey; Type: FK CONSTRAINT; Schema: sc; Owner: postgres
--

ALTER TABLE ONLY sc.itens_pedido
    ADD CONSTRAINT itens_pedido_produto_id_fkey FOREIGN KEY (produto_id) REFERENCES sc.produtos(id);


--
-- TOC entry 5091 (class 2606 OID 16978)
-- Name: movimentos_estoque movimentos_estoque_produto_id_fkey; Type: FK CONSTRAINT; Schema: sc; Owner: postgres
--

ALTER TABLE ONLY sc.movimentos_estoque
    ADD CONSTRAINT movimentos_estoque_produto_id_fkey FOREIGN KEY (produto_id) REFERENCES sc.produtos(id);


--
-- TOC entry 5092 (class 2606 OID 16983)
-- Name: movimentos_estoque movimentos_estoque_usuario_id_fkey; Type: FK CONSTRAINT; Schema: sc; Owner: postgres
--

ALTER TABLE ONLY sc.movimentos_estoque
    ADD CONSTRAINT movimentos_estoque_usuario_id_fkey FOREIGN KEY (usuario_id) REFERENCES sc.usuarios(id);


--
-- TOC entry 5096 (class 2606 OID 17079)
-- Name: pagamentos pagamentos_pedido_id_fkey; Type: FK CONSTRAINT; Schema: sc; Owner: postgres
--

ALTER TABLE ONLY sc.pagamentos
    ADD CONSTRAINT pagamentos_pedido_id_fkey FOREIGN KEY (pedido_id) REFERENCES sc.pedidos(id);


--
-- TOC entry 5093 (class 2606 OID 17021)
-- Name: pedidos pedidos_cliente_id_fkey; Type: FK CONSTRAINT; Schema: sc; Owner: postgres
--

ALTER TABLE ONLY sc.pedidos
    ADD CONSTRAINT pedidos_cliente_id_fkey FOREIGN KEY (cliente_id) REFERENCES sc.clientes(id);


--
-- TOC entry 5087 (class 2606 OID 16913)
-- Name: produtos produtos_categoria_id_fkey; Type: FK CONSTRAINT; Schema: sc; Owner: postgres
--

ALTER TABLE ONLY sc.produtos
    ADD CONSTRAINT produtos_categoria_id_fkey FOREIGN KEY (categoria_id) REFERENCES sc.categorias(id);


--
-- TOC entry 5088 (class 2606 OID 16933)
-- Name: produtos_fornecedores produtos_fornecedores_fornecedor_id_fkey; Type: FK CONSTRAINT; Schema: sc; Owner: postgres
--

ALTER TABLE ONLY sc.produtos_fornecedores
    ADD CONSTRAINT produtos_fornecedores_fornecedor_id_fkey FOREIGN KEY (fornecedor_id) REFERENCES sc.fornecedores(id);


--
-- TOC entry 5089 (class 2606 OID 16928)
-- Name: produtos_fornecedores produtos_fornecedores_produto_id_fkey; Type: FK CONSTRAINT; Schema: sc; Owner: postgres
--

ALTER TABLE ONLY sc.produtos_fornecedores
    ADD CONSTRAINT produtos_fornecedores_produto_id_fkey FOREIGN KEY (produto_id) REFERENCES sc.produtos(id);


--
-- TOC entry 5097 (class 2606 OID 17103)
-- Name: vendas vendas_pagamento_id_fkey; Type: FK CONSTRAINT; Schema: sc; Owner: postgres
--

ALTER TABLE ONLY sc.vendas
    ADD CONSTRAINT vendas_pagamento_id_fkey FOREIGN KEY (pagamento_id) REFERENCES sc.pagamentos(id);


--
-- TOC entry 5098 (class 2606 OID 17098)
-- Name: vendas vendas_pedido_id_fkey; Type: FK CONSTRAINT; Schema: sc; Owner: postgres
--

ALTER TABLE ONLY sc.vendas
    ADD CONSTRAINT vendas_pedido_id_fkey FOREIGN KEY (pedido_id) REFERENCES sc.pedidos(id);


-- Completed on 2026-10-19 18:30:51

--
-- PostgreSQL database dump complete
--

\unrestrict YsJac8VkXJLc221Ulq2NEaqJFYOOxEHu0YgK0H4B8Re4gE9GiVVTIsKh4JSJ61C

