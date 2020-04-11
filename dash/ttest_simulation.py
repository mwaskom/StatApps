import dash
import dash_core_components as dcc
import dash_html_components as html
from dash.dependencies import Input, Output

from plotly.subplots import make_subplots
import plotly.graph_objects as go

import numpy as np
from scipy import stats

# --- Define the layout of the app

external_stylesheets = ['https://codepen.io/chriddyp/pen/bWLwgP.css']
app = dash.Dash(__name__, external_stylesheets=external_stylesheets)
app.layout = html.Div([

    html.H1("Simulating t-tests"),

    dcc.Graph(id="hist-plots"),


    html.Div([
        html.H4(id="effect-label"),
        dcc.Slider(
            id="effect-slider",
            min=0,
            max=1,
            value=0,
            step=.05,
            marks={v: f"{v:.2f}" for v in np.arange(0, 1.05, .05)}
        ),
    ]),

    html.Div([
        html.H4(id="sample-label"),
        dcc.Slider(
            id="sample-slider",
            min=2,
            max=50,
            value=20,
            marks={v: "" if v % 10 else str(v) for v in range(2, 51)}

        ),
    ]),
])


# --- Add callbacks to show values for the size of the effect and sample


@app.callback(
    Output("sample-label", "children"),
    [Input("sample-slider", "value")],
)
def set_sample_label(sample_size):
    return f"Sample size: {sample_size}"


@app.callback(
    Output("effect-label", "children"),
    [Input("effect-slider", "value")],
)
def set_effect_label(effect_size):
    return f"Effect size: {effect_size:.2f}"


# --- Define the statistical simulation

@app.callback(
    Output("hist-plots", "figure"),
    [Input("effect-slider", "value"), Input("sample-slider", "value")],
)
def update_histograms(effect_size, sample_size):

    # Simulate n_sim experiments with a given true effect size and sample size
    n_sim = 1000

    # Sample data for all experiments at once
    sample = np.random.normal(effect_size, 1, (sample_size, n_sim))

    # Compute the mean and standard error for each experiment
    means = sample.mean(axis=0)
    sems = sample.std(axis=0) / np.sqrt(sample_size)

    # Compute the t statistic and corresponding (one-tailed) p value
    ts = means / sems
    ps = stats.t(sample_size - 1).sf(ts)

    # Set up the figure to show the results of the simulation
    fig = make_subplots(rows=1, cols=2, subplot_titles=("t stats", "p values"))

    fig.update_layout(shapes=[
        dict(
          type="line",
          yref="paper", y0=0, y1=1,
          xref="x2", x0=.05, x1=.05,
          line=dict(color="#999999", dash="dot")
        )
    ])

    # Plot a histogram of t statistics across all experiments
    tbins = dict(start=-10, end=10, size=.5)
    t_hist = go.Histogram(x=ts, autobinx=False, xbins=tbins, showlegend=False)
    fig.add_trace(t_hist, row=1, col=1)
    fig.update_xaxes(range=[-10, 10], row=1, col=1)
    fig.update_yaxes(range=[0, 250], row=1, col=1)

    # Plot a histogram of p values across all experiments
    pbins = dict(start=0, end=1, size=.025)
    p_hist = go.Histogram(x=ps, autobinx=False, xbins=pbins, showlegend=False)
    fig.add_trace(p_hist, row=1, col=2)
    fig.update_xaxes(range=[0, 1], row=1, col=2)
    fig.update_yaxes(range=[0, 1000], row=1, col=2)

    return fig


if __name__ == '__main__':
    app.run_server(debug=True)
