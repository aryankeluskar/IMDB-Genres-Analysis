
"""
    STL{T <: Real}
"""
struct STL{T <: Real}
    trend::Vector
    seasonal::Vector
    remainder::Vector
end

function nextodd(x::T)::Integer where T <: Real
    cx = ceil(Integer, x)
    return isodd(cx) ? cx+1 : cx
end

function sma(x, n::Integer; center::Bool = true)
    N = length(x)
    @assert 1 <= n & n <= N
    if n == 1
        return x
    end
    res = Vector{Any}(missing,N)

    # initial and final value positions
    ivp = findfirst(!ismissing, x)
    fvp = findlast(!ismissing, x)
    
    # using missing values to center ma 
    a = center ? div(n,2) : 0

    # initial moving average value
    ma = sum(x[ivp:n+ivp-1])/n
    res[a+ivp] = ma
    for i in 1:(N-n-ivp-(N-fvp)+1)
        resai = ma + (x[n+ivp+i-1] - x[ivp+i-1])/n
        # missing values are imputed
        res[a+ivp+i] = ismissing(resai) ? ma : resai
        ma = res[a+ivp+i]
    end
    return res
end

"""
    stl(Yv, np; robust=false, 
                nl=nextodd(np), 
                ns=10*length(Yv)+1,
                nt=nextodd(1.5*np/(1-1.5/ns)), 
                ni=robust ? 1 : 2,
                no=0,
                spm=false,
                qsmp=max(div(np,7),2))
    
Decompose a time series into trend, seasonal, and remainder components.
"STL has a simple design that consists of a sequence of applications of the loess smoother; the simplicity 
allows analysis of the properties of the procedure and allows fast computation, even for very long time series
and large amounts of trend and seasonal smoothing. Other features of STL  are specification of amounts of seasonal 
and trend smoothing that range, in a nearly continous way, from very small amount of smoothing to a very large 
amount; robust estimates of the trend and seasonal components that are not distorted by aberrant behavior in
the data; specification of the period of the seasonal component to any intenger multiple of the time sampling
interval greater than one; and the ability to decompose time series with missing values."*

All default values are chosen following the recommendations of the original paper when those were recommended. 
`ns` is recommended to be chosen of the basis of knowledge of the time series and on the basis of diagnostic
methods; it must nonethelessbe always odd and at least 7. A default value is not advised on the original 
paper, instead the same default value used in the stl implementation in R in usere here.
for `no` the authors advise 5 ("safe value") or 10 ("near certainty of convergence") cycles or a 
convergence criterion when robustness is required, in this case when `robust` is true computations 
stop when convergence is achieved in trend and seasonality.
for `qsmp` the authors do not adivise a default but they use a value close to div(`np`,7).

# Arguments
- `np`: Seasonality.
- `robust`: Robust stl.
- `nl`: Smoothing parameter of the low-pass filter.
- `ns`: Smoothing parameter for the seasonal component.
- `nt`: Smoothing parameter for the trend decomposition.
- `ni`: Number of inner loop cycles.
- `no`: Number of outer loop cycles.
- `spm`: Seasonal post-smoothing.
- `qsmp`: Loess q window for Seasonal post-smoothing.
- `verbose`: If true shows updates for the Seasonal and Trend convergence.
- `cth`: Corvengence threshold for Seasonal and Trend.

# Returns
An `STL` object with the seasonal, trend and remainder components.
* STL: A Seasonal, Trend Decomposition Procedure Based on Loess" Robert B. Cleveland, William S. Cleveland, Jean E. McRae, and Irma Terpenning. Journal of Official Statistics Vol. 6. No. 1, 1990, pp. 3-73 (c) Statistics Sweden.
            
# Examples
```julia-repl
julia> stl_co2 = stl(co2(),365; robust=true, spm=true)
[ Info: Dataset used in Cleveland et al. paper
[ Info: Corvengence achieved (< 0.01); Stopping computation...
STL{TimeSeries.TimeArray{Union{Missing, Float64},2,
Dates.Date,Array{Union{Missing, Float64},2}}}
(4609×3 TimeSeries.TimeArray{Union{Missing, Float64},2,
Dates.Date,Array{Union{Missing, Float64},2}} 1974-05-17 to 1986-12-31, 
"stl(Yn, np=365; nl=365, ns=46091, nt=549, ni=1, no=0, spm=true, qsmp=52)")
julia> plot(stl_co2)
```
"""
function stl(Yv::Vector{T},
             np::Integer;
             robust::Bool=false,
             nl::Integer=nextodd(np),
             ns::Integer=10*length(Yv)+1,
             nt::Integer=nextodd(1.5*np/(1-1.5/ns)),
             ni::Integer=robust ? 1 : 2,
             no::Integer=robust ? 15 : 0,
             spm::Bool=false,
             qsmp::Integer=max(div(np,7),2),
             verbose::Bool=false,
             cth::Float64 = 0.01) where T

    @assert isodd(ns) & (ns>=7) "`ns` is chosen of the basis of knowledge of the time series and on the basis of diagnostic methods; must always be odd and at least 7"

    function B(u)
        (u < 1) & !ismissing(u) ? (1.0-u^2)^2 : 0.0
    end

    N = length(Yv)
    # initial robustness weights
    rhov = ones(N)
    # intial trend
    Tv = Tv0 = zeros(N)
    Sv = Sv0 = zeros(N)
    Rv = Array{Float64,1}(undef,N)
    Cv = Array{Float64,1}(undef,N+2*np)
    scnv = false # seasonal convergence flag
    tcnv = false # trend convergence flag
    o = 0
    while robust | (o <= no)
        for k in 1:ni
            # Updating sesonal and trend components
            ## 1. Detrending (Yv = Tv + Sv)
            Sv = Yv - Tv

            ### Seasonal convergence criterion
            Md = maximum(abs.(skipmissing(Sv-Sv0)))
            M0 = maximum(skipmissing(Sv0))
            m0 = minimum(skipmissing(Sv0))
            scnv = (Md/(M0-m0) < cth)
            if verbose
                println("Outer loop: " * string(o) * " - " * "Inner loop: " * string(k))
                println("Seasonal Convergence: " * string(Md/(M0-m0)))
            end
            Sv0 = Sv

            # Seasonal Smoothing 2,3,4
            ## 2. Cycle-subseries Smoothing
            for csi in 1:np
                Cv[csi:np:N+2*np] = loess(csi:np:N,
                                          Sv[csi:np:N];
                                          q=ns,d=1,rho=rhov[csi:np:N],
                                          predict=(1.0*csi-np):np:(N+np))
            end
            ## 3. Low-Pass Filtering of Smoothed Cycle-Subseries
            ### centered support instead 1:N to balance out machine error
            Lv = loess(1-ceil(N/2):N-ceil(N/2),
                       collect(skipmissing(sma(sma(sma(Cv,np),np),3))),
                       d=1,q=nl,rho=rhov)
            ## 4. Detreending of Smoothed Cycle-Subseries
            ### Lv is substracted to prevent low-frenquency power
            ### from entering the seasonal component.
            Sv = Cv[np+1:end-np] - Lv

            ## 5. Deseasonalizing
            Dv = Yv - Sv

            # Trend Smoothing
            ## 6. Trend Smoothing
            ### centered support instead 1:N to balance out machine error
            ### (floor isntead ceil like in Lv to balance out even lengths)
            Tv = loess(1-floor(N/2):N-floor(N/2),Dv,q=nt,d=1,rho=rhov)

            ### Trend convergence criterion
            Md = maximum(abs.(skipmissing(Tv-Tv0)))
            M0 = maximum(skipmissing(Tv0))
            m0 = minimum(skipmissing(Tv0))
            tcnv = (Md/(M0-m0) < cth)
            if verbose
                println("Trend    Convergence: " * string(Md/(M0-m0)) * "\n")
            end
            Tv0 = Tv

            scnv & tcnv ? break : nothing
        end
        # Computation of robustness weights
        ## These new weights will reduce the influence of transient behaviour
        ## on the trend and seasonal components.

        # Tv and Sv defined everywhere but Rv is not defined
        # where Yv has missing values

        Rv = Yv - Tv - Sv

        if scnv & tcnv
            verbose &&  println("Corvengence achieved (< " * string(cth) * "); Stopping computation...")
            break 
        end
        
        if 0 < o <= no
            smRv = skipmissing(Rv)
            h = 6*median(abs.(smRv))
            rhov = B.(abs.(Rv)/h)
        end
        o += 1
    end

    if spm
        # Using div(np,7) as default to approximate
        # the q=51 for a np=365 chosen in the original paper
        Sv = loess(1-ceil(N/2):N-ceil(N/2),Sv,q=qsmp)
        Rv = Yv - Tv - Sv
    end
    
    if !scnv
        @warn "Seasonal convergence not achieved (>= " * string(cth) * ")
         Consider a robust estimation"
    end

    if !tcnv
        @warn "Trend convergence not achieved (>= " * string(cth) * ")
         Consider a robust estimation"
    end

    call = "stl(Yn, np="*string(np)*
        "; nl="*string(nl)*
        ", ns="*string(ns)*
        ", nt="*string(nt)*
        ", ni="*string(ni)*
        ", no="*string(no)*
        ", spm="*string(spm)*
        ", qsmp="*string(qsmp)*")"

    return STL{T}(Tv, Sv, Rv)
end