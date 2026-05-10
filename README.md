### Author: Pierre Visconti
#### M441 - Numerical Linear Algebra & Optimization - Montana State University

**Disclaimer:** This repository is provided as an academic reference and personal research record.  
Do not copy or submit this work as your own. 

---
# Modeling Earthquake Significance: Regression & Curve Fitting Analysis
[Link to full research paper](M441_least_squares.pdf)
## Overview
This project evaluates different linear and non-linear regression methods for modeling
the United States Geological Survey (USGS) significance score (sig) of earthquake events. The initial
modeling objective was to assess how well the variation in the response variable sig was explained by
the three primary predictors, magnitude, maximum instrumental intensity (MMI), and maximum
reported felt intensity (CDI). After establishing this baseline, a more complex model was constructed
by incorporating additional predictors to determine whether the explanatory power for sig could
be improved. Based on the three linear methods, Cholesky Decomposition, QR Decomposition,
and the LSQR solver in MATLAB, the more complex model had more explanatory power than the
basic one (R² of 0.52 versus 0.46)

---

## Dataset
The dataset contains **782 global earthquakes** (2001–2023) retrieved from the USGS API. Each record includes:

- magnitude  
- maximum instrumental intensity (MMI)  
- maximum reported felt intensity (CDI)  
- tsunami flag  
- rupture depth  
- latitude & longitude  
- station coverage and azimuthal gap  
- magnitude algorithm  
- significance score (**sig**)  

This mix of continuous and categorical variables makes the dataset well‑suited for regression and curve fitting.

---

## Methods

### Linear Regression
Three least‑squares solvers were implemented and compared:

- **Cholesky Decomposition**  
- **QR Decomposition**  
- **LSQR (MATLAB)**  

Two models were evaluated:

- **Baseline:** magnitude, MMI, CDI  
- **Extended:** adds tsunami indicator, magnitude algorithm, depth, latitude, longitude  

Matrix conditioning was analyzed to assess solver stability.

### Nonlinear Regression
Two nonlinear models were trained using a 70/30 train–test split:

- **Gaussian Process Regression (GPR)**  
- **Ensemble Regression Trees**  

These models were used to evaluate potential gains beyond linear methods and to study overfitting behavior.

---

## Key Results

### Linear Models
- All solvers produced identical results on the well‑conditioned baseline model (R² ≈ **0.455**).  
- The extended model improved performance to **R² ≈ 0.52**.  
- The extended model matrix was extremely ill‑conditioned (**1.34 × 10¹⁸**), causing Cholesky and QR to become unstable.  
- **LSQR remained robust** and is recommended for high‑dimensional or ill‑conditioned systems.
### Solver Comparison: R² and Coefficient Stability

#### R² Comparison (Basic vs. Updated Models)
| Method    | R² (Basic) | R² (Updated) |
|-----------|------------|--------------|
| Cholesky  | 0.455316   | 0.520139     |
| QR        | 0.455316   | 0.519467     |
| LSQR      | 0.455316   | 0.520129     |

#### Maximum Absolute Coefficient Differences
| Coefficient Pair     | Max Abs Diff (Basic)     | Max Abs Diff (Updated)     |
|----------------------|---------------------------|-----------------------------|
| Cholesky vs. QR      | 9.549694 × 10⁻¹¹          | 3.040458 × 10¹⁶             |
| Cholesky vs. LSQR    | 7.485407 × 10⁻⁷           | 1.373069 × 10³              |
| QR vs. LSQR          | 7.485568 × 10⁻⁷           | 3.040458 × 10¹⁶             |
### Linear Model Performance

<table>
<tr>
<td>

#### Basic Model
<table>
<tr><th>Method</th><th>Train R²</th><th>Test R²</th></tr>
<tr><td>Cholesky</td><td>0.4382</td><td>0.4924</td></tr>
<tr><td>QR</td><td>0.4382</td><td>0.4924</td></tr>
<tr><td>LSQR</td><td>0.4382</td><td>0.4924</td></tr>
</table>

</td>
<td>

#### Updated Model
<table>
<tr><th>Method</th><th>Train R²</th><th>Test R²</th></tr>
<tr><td>Cholesky</td><td>0.5115</td><td>0.5323</td></tr>
<tr><td>QR</td><td>0.5115</td><td>0.5327</td></tr>
<tr><td>LSQR</td><td>0.5114</td><td>0.5322</td></tr>
</table>

</td>
</tr>
</table>


---

### Nonlinear Models
- GPR and Ensemble Trees achieved higher training R² (0.78–0.79) but lower test R² (0.57–0.59).  
- Both models showed **overfitting**, especially GPR.  
- Nonlinear methods did not generalize better than the extended linear model.

### Nonlinear Model Performance

<table>
<tr>
<td>

#### Basic Model
<table>
<tr><th>Method</th><th>Train R²</th><th>Test R²</th></tr>
<tr><td>GPR</td><td>0.5555</td><td>0.6277</td></tr>
<tr><td>Ensemble Trees</td><td>0.6190</td><td>0.5902</td></tr>
</table>

</td>
<td>

#### Updated Model
<table>
<tr><th>Method</th><th>Train R²</th><th>Test R²</th></tr>
<tr><td>GPR</td><td>0.7788</td><td>0.5767</td></tr>
<tr><td>Ensemble Trees</td><td>0.7921</td><td>0.5927</td></tr>
</table>

</td>
</tr>
</table>


---

## Conclusion
The project demonstrates that:

- Conditioning strongly determines solver reliability in linear regression.  
- **LSQR** is the most stable method for ill‑conditioned or high‑dimensional problems.  
- Adding geophysical predictors improves explanatory power for earthquake significance.  
- Nonlinear models require tuning to avoid overfitting and do not outperform the extended linear model in generalization.
