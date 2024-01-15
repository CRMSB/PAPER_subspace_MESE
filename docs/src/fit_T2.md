# Fitting the data

The reconstruction and the fitting parts are totally independent.

The fitting functions expects a multidimensionnal-array with the echoes along the last dimension. The images should not be in complex, remember to use `abs.(img)`

## Exponential $T_2$ fitting + noise

In the publication we used an analytical model to fit the exponential decay of the echoes :

```math
S(t) = \sqrt{\left(M_0 \ exp(-\frac{t}{T_2})\right)^2 + 2 \ L \ \sigma_g^2}
```
where L is the number of coil and $\sigma_g$ corresponds to the gaussian noise level on image

You can perform this fit with the following function :

```@docs
T2Fit_exp_noise
```

The keyword `removePoint` can be used to delete the first point in the TE vector as well as the first temporal volume in order to reduce the sensitivity of the fit to the stimulated echo.

## EPG $T_2$ fitting + noise (WIP)

Another possibility is to fit the equation with an EPG model that, in addition to $M_0$/$T_2$/$\sigma$, also fit the $B_1$ field.

With the current implementation, the fit is not robust enough  and also takes too long to use on a volumic volume.
```
T2Fit_epg_noise
```