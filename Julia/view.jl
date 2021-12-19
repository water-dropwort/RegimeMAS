include("./society.jl")

using Plots

# ヒートマップ描画
function draw_heatmap(society, label)
    xylim   = (0, society.agentN + 1)
    # 各エージェントのヒートマップを生成
    hm_gov = _heatmap(society.gov, society.regimeN)
    hm_ind = _heatmap(society.ind, society.regimeN)
    hm_ngo = _heatmap(society.ngo, society.regimeN)
    # ヒートマップ描画
    return plot( hm_gov, hm_ind, hm_ngo
                 ,title = ["Govenment" "Industry" "NGO"]
                 ,xlabel = label
                 ,aspect_ratio = 1
                 ,titlefontsize=9
                 ,clim = (1,society.regimeN + 1)
                 ,ylim = xylim, xlim = xylim
                 ,layout=(3,1)
                 ,size=(800,800))
end

# ヒートマップ
_heatmap(regimes, regimeN) = heatmap(regimes, color=palette(:tab10, regimeN))

# ヒートマップ描画(2時点をならべて表示)
function draw_heatmap2t(society1, society2)
    hm1 = draw_heatmap(society1)
    hm2 = draw_heatmap(society2)

    return plot(hm1, hm2, layout=(1,2))
end
