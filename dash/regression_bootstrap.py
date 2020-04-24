import dash
import dash_core_components as dcc
import dash_html_components as html
from dash.dependencies import Input, Output
import dash_bootstrap_components as dbc

import numpy as np
from scipy import stats


# --- Define the underlying regression model

rng = np.random.default_rng()
n_obs = 30
n_boot = 20

# Simple y = ax + b + noise model
x = rng.uniform(-3, 3, n_obs)
y = 2 + .75 * x + rng.normal(0, 1.5, n_obs)

# Fit a regression using OLS
fit = np.polyfit(x, y, 1)
xx = np.linspace(-3.5, 3.5, 101)
yhat = np.polyval(fit, xx)

# Compute the analytic confidence interval for the regression
dof = n_obs - 2
xbar = x.mean()
ss_x = np.sum(np.square(x - xbar))
s = np.sqrt(np.sum(np.square(y - np.polyval(fit, x))) / dof)
se_x = s * np.sqrt(1 / n_obs + np.square(xx - xbar) / ss_x)
z = stats.t(dof).ppf(.975)
ci = yhat - z * se_x, yhat + z * se_x

# Fit the regression for a small number of bootstrap samples
boot_samples = []
yhat_boots = []
for _ in range(n_boot):
    sampler = np.random.randint(0, n_obs, n_obs)
    x_boot = x[sampler]
    y_boot = y[sampler]
    fit_boot = np.polyfit(x_boot, y_boot, 1)
    boot_samples.append(sampler)
    yhat_boots.append(np.polyval(fit_boot, xx))


# --- Define the layout of the app

external_stylesheets = ['https://codepen.io/chriddyp/pen/bWLwgP.css']
app = dash.Dash(__name__, external_stylesheets=external_stylesheets)

app.layout = dbc.Container([

    html.H1("Confidence intervals on regression model"),

    dcc.Graph(
        id="plot",
        clear_on_unhover=True,
    ),

    dcc.RadioItems(
        id="hover-action",
        options=[
            {"label": "Show observations included in bootstrap sample",
             "value": "bootstrap"},
            {"label": "Show analytic distribution of error around estimate",
             "value": "error"},
        ],
        value="bootstrap",
    ),

])


# --- Define the interaction with the graph

@app.callback(
    Output("plot", "figure"),
    [Input("hover-action", "value"),
     Input("plot", "hoverData")],
)
def plot_scatter(hover_action, hover_data):

    # Set up the figure
    layout = {
        "width": 800,
        "height": 600,
        "xaxis": {"range": (-4, 4), "title": "x"},
        "yaxis": {"range": (-3, 7), "title": "y"},
        "hovermode": 'closest',
    }

    # Set default element parameters
    line_color = "#222299"
    boot_red = "#cc2222"
    boot_gray = "#999999"
    scatter_color = "#222222"
    scatter_size = 10

    # Process the hover action
    hover_line = None
    hover_point = None
    if hover_data is not None:
        hover_element = hover_data["points"][0]
        hover_line = hover_element["curveNumber"]
        hover_point = hover_element["pointIndex"]

    # Set up the list of graph elements
    data = []

    # Define the parameters of the bootstrap sample lines, based on hover
    show_bootstrap_sample = (
        hover_action == "bootstrap"
        and hover_line is not None
        and hover_line < n_boot
    )
    if show_bootstrap_sample:
        hover_sample = hover_line
        used, count = np.unique(boot_samples[hover_sample], return_counts=True)
        show_obs = np.in1d(np.arange(n_obs), used)
        scatter_color = np.where(show_obs, boot_red, boot_gray)
        scatter_size = np.full(n_obs, 10)
        scatter_size[show_obs] = 10 * np.sqrt(count)

    # Plot the regression line for each bootstrap sample
    for i, yhat_boot in enumerate(yhat_boots):

        width = 1.5
        color = boot_gray

        if hover_action == "bootstrap" and i == hover_line:
            width = 2.5
            color = boot_red

        data.append({
            "x": xx, "y": yhat_boot,
            "mode": "lines", "showlegend": False,
            "line": {"color": color, "width": width},
            "hoverinfo": "none" if hover_action == "bootstrap" else "skip",
        })

    # Plot the regression estimate and its confidence interval
    data.extend([
        {
            "x": xx, "y": yhat,
            "mode": "lines", "showlegend": False,
            "line": {"color": line_color, "width": 3},
            "hoverinfo": "none" if hover_action == "error" else "skip",
        },
        {
            "x": xx, "y": ci[0],
            "mode": "lines", "showlegend": False,
            "line": {"color": line_color, "width": 0},
            "hoverinfo": "skip",
        },
        {
            "x": xx, "y": ci[1],
            "mode": "lines", "showlegend": False,
            "line": {"color": line_color, "width": 0},
            "fill": "tonexty", "fillcolor": line_color + "33",
            "hoverinfo": "skip",
        }
    ])

    # Plot the observations
    data.append({
        "x": x, "y": y,
        "mode": "markers", "showlegend": False,
        "marker": {"color": scatter_color, "size": scatter_size},
        "hoverinfo": "skip",
    })

    # Plot the error distribution around the regression estimate
    show_yhat_error = (
        hover_action == "error"
        and hover_point is not None
        and hover_line == n_boot
    )
    if show_yhat_error:

        err_loc = yhat[hover_point]
        err_sd = se_x[hover_point]
        err_y = np.linspace(err_loc - err_sd * 5, err_loc + err_sd * 5, 100)
        err_dist = stats.t(dof, loc=err_loc, scale=err_sd)
        err_x = xx[hover_point] + err_dist.pdf(err_y) * .5

        data.extend([
            {
                "x": np.full_like(err_y, xx[hover_point]), "y": err_y,
                "mode": "lines", "showlegend": False,
                "line": {"color": boot_red, "width": 1, "dash": "dash"},
                "hoverinfo": "skip",
            },
            {
                "x": err_x, "y": err_y,
                "mode": "lines", "showlegend": False,
                "line": {"color": boot_red, "width": 3},
                "hoverinfo": "skip",
            },
        ])

    fig = {
        "data": data,
        "layout": layout,
    }

    return fig


if __name__ == '__main__':
    app.run_server(debug=True)
