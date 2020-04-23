import dash
import dash_core_components as dcc
import dash_html_components as html
from dash.dependencies import Input, Output
import dash_bootstrap_components as dbc

import plotly.graph_objects as go

import numpy as np
import statsmodels.api as sm


# --- Define the underlying regression model

true_intercept = 2
true_slope = 1.25

n_obs = 50
x = np.random.normal(0, 2, n_obs)
y = true_intercept + true_slope * x + np.random.normal(0, 1, n_obs)

intercept_options = np.arange(-2, 6.5, .5)
starting_intercept = np.random.choice(intercept_options)

slope_options = np.arange(-1, 3.25, .25)
starting_slope = np.random.choice(slope_options)


# --- Define the layout of the app

app = dash.Dash(__name__, external_stylesheets=[dbc.themes.BOOTSTRAP])

app.layout = dbc.Container([

    html.H1("Simple linear regression"),

    html.Div([
        dbc.Row([
            dbc.Col(
                dcc.Graph(id="scatter-plot"),
                width=6,
            ),
            dbc.Col([
                dbc.Row([
                    dcc.Graph(id="score-plot"),
                    dcc.Graph(id="resid-plot"),
                ]),
            ], width=6),
        ]),
    ]),

    html.Div([
        html.H4("Intercept", id="intercept-label"),
        dcc.Slider(
            id="intercept-slider",
            min=-2,
            max=6,
            step=.5,
            value=starting_intercept,
            marks={val: "" for val in intercept_options},
        ),
    ]),

    html.Div([
        html.H4("Slope", id="slope-label"),
        dcc.Slider(
            id="slope-slider",
            min=-1,
            max=3,
            step=.25,
            value=starting_slope,
            marks={val: "" for val in slope_options},
        ),
    ]),

    dcc.Checklist(
        id="results-check",
        options=[
            {"label": " Show OLS fit results", "value": "true"},
        ],
    ),

    html.Pre(id="results-text"),

])


@app.callback(
    Output("intercept-label", "children"),
    [Input("intercept-slider", "value")],
)
def label_intercept(intercept):
    return f"Intercept = {intercept:.1f}"


@app.callback(
    Output("slope-label", "children"),
    [Input("slope-slider", "value")],
)
def label_slope(slope):
    return f"Slope = {slope:.1f}"


# --- Draw a scatter plot of the data and the specified regression line


@app.callback(
    Output("scatter-plot", "figure"),
    [Input("intercept-slider", "value"), Input("slope-slider", "value")],
)
def plot_scatter(intercept, slope):

    fig = go.Figure()
    fig.update_layout(
        width=500, height=500,
    )
    fig.update_xaxes(range=(-5, 5), title="x")
    fig.update_yaxes(range=(-3, 7), title="y")

    fig.add_trace(go.Scatter(x=x, y=y, mode="markers", showlegend=False))

    xx = np.linspace(-5, 5, 100)
    yy = intercept + slope * xx
    best_fit = intercept == true_intercept and slope == true_slope
    color = "#636EFA" if best_fit else "#EF553B"
    fig.add_trace(go.Scatter(x=xx, y=yy, mode="lines",
                             line=dict(color=color),
                             showlegend=False))

    return fig


# --- Show the residual sum of squares and compare to fit using true values


@app.callback(
    Output("score-plot", "figure"),
    [Input("intercept-slider", "value"), Input("slope-slider", "value")],
)
def plot_score(intercept, slope):

    yhat = intercept + slope * x
    ss_res = np.sum(np.square(y - yhat))

    y_opt = true_intercept + true_slope * x
    ss_res_opt = np.sum(np.square(y - y_opt))

    fig = go.Figure()
    fig.update_layout(
        width=500, height=200,
    )
    fig.update_xaxes(range=(0, 1000), title="Sum of squares of residuals")
    fig.update_yaxes(range=(0, 1), showticklabels=False)

    best_fit = intercept == true_intercept and slope == true_slope
    fig.add_trace(go.Scatter(x=[ss_res, ss_res_opt], y=[.5, .5],
                  mode="markers", marker_size=10,
                  marker_symbol=["asterisk-open", "circle-open"],
                  marker_color=[
                    "#636EFA" if best_fit else "#EF553B", "#636EFA",
                  ],
                  marker_line_width=2,
                  showlegend=False))

    return fig


# --- Show the distribution of the residuals


@app.callback(
    Output("resid-plot", "figure"),
    [Input("intercept-slider", "value"), Input("slope-slider", "value")],
)
def plot_residuals(intercept, slope):

    yhat = intercept + slope * x
    residuals = y - yhat
    best_fit = intercept == true_intercept and slope == true_slope

    fig = go.Figure()
    fig.update_layout(
        width=500, height=300,
    )
    fig.update_xaxes(range=(-5, 5), title="Residuals")
    fig.update_yaxes(range=(0, 20), title="Count")

    bins = dict(start=-5, end=5, size=.5)
    fig.add_trace(
        go.Histogram(x=residuals,
                     marker_color="#636EFA" if best_fit else "#EF553B",
                     autobinx=False, xbins=bins, showlegend=False),
    )

    fig.update_layout(shapes=[
        dict(
          type="line",
          yref="paper", y0=0, y1=1,
          xref="x1", x0=0, x1=0,
          line=dict(color="#999999", dash="dot")
        ),
    ])

    return fig


@app.callback(
    Output("results-text", "children"),
    [Input("results-check", "value")],
)
def print_ols_fit(checked):
    if checked:
        m = sm.OLS(y, sm.add_constant(x)).fit()
        return m.summary().as_text()
    else:
        return ""


if __name__ == '__main__':
    app.run_server(debug=True)
