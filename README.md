# 🧠 DepScan: Student Depression Prediction Model

Depression is one of the most pressing - yet often hidden - challenges faced by students today. **DepScan** is a machine learning model designed to detect potential depression in students based on academic, personal, and lifestyle indicators. Our goal is not to replace clinical intervention, but to **support early, proactive, and empathetic action** from educational institutions and healthcare providers.

---

## 📦 Dataset Description

- **Source:** [Kaggle - Student Depression Dataset](https://www.kaggle.com/datasets/adilshamim8/student-depression-dataset)
- **Owner:** Adil Shamim
- **Format:** CSV (each row = one student)
- **Sample Size:** 27,901 student records
- **Files Used:** `student_depression_dataset.csv`
- **Target Variable:** `Depression` (Binary: 0 = No Depression, 1 = Depression)
- **Key Features:**
  - **Demographics:** Age, Gender, City
  - **Academics:** CGPA, Academic Pressure, Degree
  - **Lifestyle:** Sleep Duration, Dietary Habits, Work/Study Hours
  - **Mental Health Indicators:** Suicidal thoughts, Financial stress, Family history

> **Note:** The dataset represents Indian student populations, which makes cultural context important. Future versions should validate across global populations for generalizability.

---

## 📊 Key Features of the Model

- **Academic Pressure**: Level of stress from academic workload
- **Financial Stress**: Pressure due to financial difficulties
- **Study Satisfaction**: Student’s contentment with academic environment
- **Sleep Duration**: Average hours of sleep per day
- **Suicidal Thoughts**: Self-reported suicidal ideation (Yes/No)
- **CGPA**: Cumulative grade point average
- **Work Pressure**: Stress from part-time jobs or academic duties
- **Family History of Mental Illness**: Genetic predisposition (Yes/No)

These features showed strong predictive power for identifying depressive symptoms in students during model training.

---

## 🧪 Model Performance

| Model         | Accuracy |
|---------------|----------|
| Random Forest | 83.6%    |
| XGBoost       | 85.0%    |

> _Both models were trained on 80% of the data and validated on the remaining 20%._

---

## 🛠️ Model Revisions

### 🔁 Week of June 30 – July 6, 2025
- Switched from Random Forest to **XGBoost**
- Added one-hot encoding for categorical variables
- Introduced **early stopping** to avoid overfitting
- Tuned hyperparameters: `max_depth = 6`, `eta = 0.03`
- Improved test accuracy from **83.6% → 85.0%**

> **Note:** This section is updated weekly to track changes in model design and performance.
---

## 💻 How to Use

1. Clone this repository  
2. Run the script (`studep_xgb_model.R`) in RStudio 
3. Load the dataset or use your own  
4. View predictions and performance metrics

---

## 💻 User Experience

Visit this repository to:

- 📁 Explore the latest XGBoost model and dataset  
- 📉 View top predictive features (e.g., academic pressure, financial stress)  
- 🧪 Test the model using mock or institutional data  
- ⚙️ Access API-ready endpoints for integration (coming soon)  
- 📘 Read about ethical considerations, dataset privacy, and limitations

The project also includes:

- Visual walkthroughs (feature importance plots, confusion matrix, and performance logs)  
- A quick-start `.R` script to run the model on your own data  
- Clear documentation and examples for R users  

---

## 🎯 Use Cases

- **Universities**: Embed in wellness check-ins or orientation programs to identify at-risk students early.  
- **Counselors**: Use predictions as supportive insight during counseling sessions.  
- **Researchers**: Analyze depression trends and associated lifestyle or academic factors.  
- **NGOs / Policy Makers**: Inform mental health program design for youth and student communities.

---

## ⚠️ Ethical Note

This model is not a medical diagnostic tool. It supports early identification, not clinical diagnosis. Please ensure **student privacy**, **consent**, and **data security** are strictly upheld when deploying or analyzing results.

---

## 📎 Files Included

| File                     | Description                                             |
|--------------------------|---------------------------------------------------------|
| `student_depression_dataset.csv` | Cleaned and anonymized student dataset          |
| `studep_xgb_model.R`             | Code for data preprocessing, XGBoost training, and evaluation |
| `xgb_studep_model.model`         | Saved XGBoost model file                        |
| `README.md`                      | Project overview, instructions, and documentation |

---

## 🙏 Acknowledgements

Special thanks to **Adil Shamim** for compiling and sharing the dataset via Kaggle:  
🔗 [Student Depression Dataset on Kaggle](https://www.kaggle.com/datasets/adilshamim8/student-depression-dataset)

---

## 📫 Contact

For feedback, collaboration, or deployment support, reach out via:  
🔗 [LinkedIn](https://www.linkedin.com/in/gokulv17/)

---

> _Let’s make mental health support more proactive, data-driven, and compassionate._
