from p33py.df import df
from p33py.metrics import metric_DEI_FourG_twoScopes

def calculate():
    return metric_DEI_FourG_twoScopes(df,
                                                 'metric_hs_apcs_aboveThree',
                                                 'proficiency',
                                                 'hs',
                                                       0.5,
                                                 '2021___city_chi___hs___apcs_score3/4',
                                                 '2021___usa___hs___apcs_score3/4',
                                                 '2021___city_chi___hs_apcs___popul___cps',
                                                 '2021___usa___hs_apcs___popul')
