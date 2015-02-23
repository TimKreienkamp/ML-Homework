interval_selection <- function(bias, n){
  
  if (!require("ggplot2")) install.packages("ggplot2")
  if (!require("rPython")) install.packages("rPython")
  library(gplot2)
  library(rPython)
  
  
  ##########################################
  #python function definitions
  ###########################################
  
  
  python.exec('import numpy as np')
  python.exec("def _sim_data(intervals, ndraws, bias):
  x = np.random.uniform(0, 1, ndraws)
  is_in_int = np.vectorize(lambda x:
                            np.any(np.apply_along_axis(lambda int: int[0] <= x <= int[1], 1, intervals)))
  y = np.where(
    is_in_int(x), 
    np.random.binomial(1, 0.5 + bias, ndraws), 
    np.random.binomial(1, 0.5 - bias, ndraws)
    )
  return(np.sort(x), y[np.argsort(x)])")

  
  python.exec('def selection(y, nint, save_all = True):
  
  classifiers = []
  g = _init(y)
  
  if len(g) % 2 != nint % 2:
      if g[1]["adv"] > g[-1]["adv"]:
            g[-2]["adv"] -= g[-1]["adv"]
            g[-2]["cutoff"] = g[-1]["cutoff"]
            g.pop()
      else:
            g[1]["adv"] -= g[0]["adv"]
            g.popleft()
  
  (save_all and classifiers.append(copy(g)))
  
  all((_dp(g), save_all and classifiers.append(copy(g))) for i in range((len(g) - nint) / 2))
  
  

  return(save_all and classifiers or [g])')
  
  python.exec('def _init(y):
    g_n = deque()
    g_n.append({"cutoff": 0, "label": y[0], "adv": 1})
    for i in range(1, len(y)):
      if y[i] == g_n[-1]["label"]:
        g_n[-1]["cutoff"] += 1
        g_n[-1]["adv"] += 1
      else:
          g_n.append({"cutoff": i, "label": y[i], "adv": 1})
    return g_n')
  
  python.exec('def _dp(g):
    
    outer_adv = g[1]["adv"] + g[-1]["adv"]
    inner_adv = [interval["adv"] for interval in g]
    del inner_adv[-1], inner_adv[0]
  
    if outer_adv > np.max(inner_adv):
      g.rotate(-(np.argmin(inner_adv) + 1))
      g[-1]["adv"] = g[-1]["adv"] - g[0]["adv"] + g[1]["adv"]
      g[-1]["cutoff"] = g[1]["cutoff"]
      (g.popleft(), g.popleft(),  g.rotate(np.argmin(inner_adv) + 1))
    else:
        g[1]["adv"] -= g[0]["adv"]
        g[-2]["adv"] -= g[-1]["adv"]
        g[-2]["cutoff"] = g[-1]["cutoff"]
        (g.pop(), g.popleft())')
  python.exec('def predict(pred_intervals, x_val):
      is_in_int = np.vectorize(lambda x:
          np.any(np.apply_along_axis(lambda int: int[0] <= x <= int[1], 1, pred_intervals)))
      y_pred = float(is_in_int(x_val))
      return y_pred')
 
  ####################################
  #python function execution
  #####################################
  
  
  python.exec("intervals = np.array([[0.1,0.5],[0.9,1.0]])")
  python.exec("x,y = _sim_data(intervals, ndraws,bias)")
  python.exec("y = y.tolist()")
  python.exec("x = x.tolist()")
  y = python.get("y")
  x = python.get("x")
  
  python.assign("bias", bias)
  python.assign("ndraws", n)
  
  
  ######################################
  #collection everything back into R
  ######################################
  out_list = list(x=x,y=y)
    
}


