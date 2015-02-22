from collections import deque
from copy import copy
import numpy as np


def selection(y, nint):

    classifiers = deque()
    g = _init(y)

    if len(g) % 2 != nint % 2:
        if g[1]["adv"] > g[-1]["adv"]:
            g[-2]["adv"] -= g[-1]["adv"]
            g[-2]["cutoff"] = g[-1]["cutoff"]
            g.pop()
        else:
            g[1]["adv"] -= g[0]["adv"]
            g.popleft()
    
    classifiers.append(copy(g))

    all((_dp(g), classifiers.append(copy(g))) for i in range((len(g) - nint) / 2))

    return(classifiers)


def _init(y):
    g_n = deque()
    g_n.append({"cutoff": 0, "label": y[0], "adv": 1})
    for i in range(1, len(y)):
        if y[i] == g_n[-1]["label"]:
            g_n[-1]["cutoff"] += 1
            g_n[-1]["adv"] += 1
        else:
            g_n.append({"cutoff": i, "label": y[i], "adv": 1})
    return g_n
            

def _dp(g):

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
        (g.pop(), g.popleft())


def _sim_data(intervals, ndraws, bias):
     x = np.random.uniform(0,1,ndraws)
     print(x)
     is_in_int = np.vectorize(lambda x:
         np.any(np.apply_along_axis(lambda int: int[0] <= x <= int[1], 1, intervals)))
     print(is_in_int(x))
     y = np.where(
         is_in_int(x), 
         np.random.binomial(1, 0.5 + bias), 
         np.random.binomial(1, 0.5 - bias)
         )
     return (np.sort(x), y[np.argsort(x)])




intervals = np.array([[0.1,0.5],[0.9,1.0]])
x, y = _sim_data(intervals, 10, 0)
