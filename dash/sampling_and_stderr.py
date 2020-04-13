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

    html.H1("Sampling and standard error"),

    dcc.Graph(id="plots"),


    html.Div([
        html.H4("Population standard deviation", id="population-label"),
        dcc.Slider(
            id="population-slider",
            min=4,
            max=20,
            value=12,
            step=1,
            marks={v: "" if v % 4 else f"{v/4:.0f}" for v in range(21)},
        ),
    ]),

    html.Div([
        html.H4("Sample size", id="sample-label"),
        dcc.Slider(
            id="sample-slider",
            min=0,
            max=200,
            value=100,
            step=10,
            marks={v: "" if v % 50 else str(v) for v in range(0, 210, 10)},
        ),
    ]),
])


# --- Define the statistical simulation

@app.callback(
    Output("plots", "figure"),
    [Input("population-slider", "value"), Input("sample-slider", "value")],
)
def update_histograms(population, sample_size):

    # Define the population distribution
    sd = population / 4  # Because of bug in slider with float values
    d = stats.norm(0, sd)

    # Simulate n_sim experiments with a given true effect size and sample size
    n_sim = 1000

    # Set up the figure to show the results of the simulation
    fig = make_subplots(
        rows=1, cols=3,
        shared_xaxes=True,
        subplot_titles=[
            "Generating distribution",
            f"Distribution of one sample (N = {sample_size})",
            f"Distribution of means from {n_sim} samples",
        ]
    )

    fig.update_layout(shapes=[
        dict(
          type="line",
          yref="paper", y0=0, y1=1,
          xref="x2", x0=.05, x1=.05,
          line=dict(color="#999999", dash="dot")
        )
    ])

    # Plot the probability density function of the population
    x = np.linspace(-12, 12, 5001)
    y = d.pdf(x)
    t_hist = go.Scatter(x=x, y=y, mode="lines", showlegend=False)
    fig.add_trace(t_hist, row=1, col=1)
    fig.update_yaxes(range=[0, .55], row=1, col=1)

    # Plot a histogram of one sample
    sample = d.rvs(sample_size)
    bins = dict(start=-12, end=12, size=1)
    hist = go.Histogram(x=sample, autobinx=False, xbins=bins, showlegend=False)
    fig.add_trace(hist, row=1, col=2)
    fig.update_xaxes(range=[-12, 12], row=1, col=2)
    fig.update_yaxes(range=[0, sample_size * .75], row=1, col=2)

    # Plot a histogram of the means from many samples
    samples = d.rvs((sample_size, n_sim))
    means = samples.mean(axis=0)
    bins = dict(start=-12, end=12, size=.2)
    hist = go.Histogram(x=means, autobinx=False, xbins=bins, showlegend=False)
    fig.add_trace(hist, row=1, col=3)
    fig.update_xaxes(range=[-12, 12], row=1, col=3)
    fig.update_yaxes(range=[0, n_sim * .55], row=1, col=3)

    return fig


if __name__ == '__main__':
    app.run_server(debug=True)
