# 社会モデル
struct Society
    # 政府エージェントが選択しているレジーム
    gov     :: Matrix{Int}
    # 産業界エージェントが選択しているレジーム
    ind     :: Matrix{Int}
    # NGOエージェントが選択しているレジーム
    ngo     :: Matrix{Int}
    # sqrt(エージェントの数)。agentN × agentNのマトリックスを考える。
    agentN  :: Int
    # レジームの選択肢。1 ~ regimeN が各エージェントが取る戦略である。
    regimeN :: Int

    # コンストラクタ
    function Society(gov, ind, ngo, regimeN)
        return new(gov, ind, ngo, size(gov,1), regimeN)
    end
end

# 初期状態生成
function init_society(agentN, regimeN)
    _gov = init_regimes(agentN, regimeN)
    _ind = init_regimes(agentN, regimeN)
    _ngo = init_regimes(agentN, regimeN)
    return Society(_gov, _ind, _ngo, regimeN)
end

# モデルを更新する
update(society, gov_nx, ind_nx, ngo_nx) = Society(gov_nx, ind_nx, ngo_nx, society.regimeN)

# 独自選好生成
function generate_idprfs(agentN, regimeN)
    idprfs = Matrix{Array{Float64,1}}(undef, agentN, agentN)
    for (i,j) in Iterators.product(1:agentN, 1:agentN)
        idprfs[i,j] = rand(regimeN)
    end
    return idprfs
end


# 初期レジーム生成 --> Matrix{Int}
function init_regimes(agentN, regimeN)
    return rand(1:regimeN, agentN, agentN)
end
