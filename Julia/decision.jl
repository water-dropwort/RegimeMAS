using LinearAlgebra
include("./society.jl")

# t時点の社会を引数にとり、t+1時点の社会を返す。
function decision_regime(society, gidprfs, weights)
    # 産業界/NGOエージェントの独自選好を、乱数で生成。
    iidprfs = generate_idprfs(society.agentN, society.regimeN)
    nidprfs = generate_idprfs(society.agentN, society.regimeN)
    return _decision_regime(society, gidprfs, iidprfs, nidprfs, weights)
end


# t時点の社会を引数にとり、t+1時点の社会を返す。
# 産業界/NGOエージェントの独自選好は毎ターン変わるルールのため、引数として与えている。
function _decision_regime(society, gidprfs, iidprfs, nidprfs, weights)
    # 次ターンのレジームを格納する配列を生成
    gov_nx = zeros(Int, society.agentN, society.agentN)
    ind_nx = zeros(Int, society.agentN, society.agentN)
    ngo_nx = zeros(Int, society.agentN, society.agentN)

    # 政府エージェントの各レジームのシェア
    gshares = shares(society.gov, society.regimeN)

    # 各国を走査
    for (i,j) in Iterators.product(1:society.agentN, 1:society.agentN)
        # 近隣国のエージェントのシェア
        lshrs = lshares((i,j), society.gov, society.regimeN, society.agentN)

        # 各エージェントの選好を計算する。
        gprefs = calc_gprefs(gidprfs[i,j], gshares, lshrs, society.ind[i,j], society.ngo[i,j], society.regimeN, weights[1:5])
        iprefs = calc_i_n_prefs(iidprfs[i,j], gshares, society.gov[i,j], society.regimeN, weights[9:11])
        nprefs = calc_i_n_prefs(nidprfs[i,j], gshares, society.gov[i,j], society.regimeN, weights[6:8])

        # 最も選好の高かったレジームをセットする。
        gov_nx[i,j] = best_regime(gprefs)
        ind_nx[i,j] = best_regime(iprefs)
        ngo_nx[i,j] = best_regime(nprefs)
    end
    return update(society, gov_nx, ind_nx, ngo_nx)
end

# Bool -> (1 or 0)
bool2bin(t) = t ? 1 : 0

# 政府エージェントの各レジームの選好を配列にして返す。
function calc_gprefs(gidprf, gshares, lshares, iregime, nregime, regimeN, weights)
    gprefs = zeros(regimeN)
    for r in (1:regimeN)
        δind = bool2bin(r == iregime)
        δngo = bool2bin(r == nregime)
        gprefs[r] = dot(weights, [gidprf[r], gshares[r], lshares[r], δngo, δind])
    end
    return gprefs
end

# NGO/産業界エージェントの各レジームの選好を配列にして返す。
function calc_i_n_prefs(idprf, gshares, gregime, regimeN, weights)
    prefs = zeros(regimeN)
    for r in (1:regimeN)
        δgov = bool2bin(r == gregime)
        prefs[r] = dot(weights, [idprf[r], gshares[r], δgov])
    end
    return prefs
end

# 選好が高いレジームを返す。
# 選好が同じ場合は、より数字の大きいレジームを返す。
best_regime(prefs) = maximum(Iterators.zip(prefs, 1:length(prefs)))[2]

# 隣接8国のレジームのシェアを求める。
# 隅の国については、トーラス形を想定して、処理する。
function lshares(center, regimes, regimeN, agentN)
    shr = zeros(regimeN)
    idx = (x -> (x < 1) ? agentN : ((x > agentN) ? 1 : x))

    for (i,j) in Iterators.product(-1:1, -1:1)
        if (i != 0 || j != 0)
            r = regimes[idx(center[1] + i), idx(center[2] + j)]
            shr[r] = shr[r] + 1
        end
    end
    return shr ./ 8
end


# 各レジームのシェアを求める
function shares(regimes, regimeN)
    shr = zeros(regimeN)
    for reg in (1:regimeN)
        shr[reg] = count(==(reg), regimes) / length(regimes)
    end
    return shr
end
