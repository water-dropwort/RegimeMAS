module RegimeMAS
using Plots

include("./society.jl")
include("./decision.jl")
include("./view.jl")

# アニメーション
# 参考資料に掲載されている w パラメータの設定
function run()
    anim = Animation()

    wss = [[3,1,4,0,0,2,0,0,1,0,0],
           [3,1,4,0,0,2,5,2,1,0,0],
           [3,1,4,1,0,2,5,2,1,0,0],
           [3,1,4,1,0,2,5,2,1,1,1]]

    _society = init_society(20,5)
    gidprfs = generate_idprfs(20, 5)

    frame(anim, draw_heatmap(_society, "t = 0"))

    t_tmp = 0
    for i in (1:length(wss))
        # 同じ重みづけの設定で数回実行。
        for t in (1:10)
            _society = decision_regime(_society, gidprfs, wss[i])
            t_tmp = t_tmp + 1
            frame(anim, draw_heatmap(_society, "t = $t_tmp"))
        end
    end

    gif(anim, "mas.gif", fps = 3)
end

end # end of module
