# 🧠 DepScan: Student Depression Prediction Model

Depression is one of the most pressing — yet often hidden — challenges faced by students today. **DepScan** is a machine learning model designed to detect potential depression in students based on academic, personal, and lifestyle indicators. Our goal is not to replace clinical intervention, but to **support early, proactive, and empathetic action** from educational institutions and healthcare providers.

---

## 📊 Data & Model

The model is trained on **27,901 anonymized student records**, with features covering:

- **Academic performance** (e.g., CGPA, academic pressure)  
- **Lifestyle habits** (e.g., sleep hours, phone usage)  
- **Mental health indicators** (e.g., suicidal thoughts, anxiety, family history of mental illness)

We used a **Random Forest classifier**, chosen for its high accuracy (**83% on test data**) and interpretability.

> **Note:** The dataset represents Indian student populations, which makes cultural context important. Future versions should validate across global populations for generalizability.

---

## ⚙️ Features

- **Input Type:** Structured survey-like fields (non-invasive)  
- **Model Type:** Random Forest (tuned `ntree=1000`, optimized `mtry`)  
- **Accuracy:** ~83% test accuracy  
- **Outputs:** Depression classification (`Yes` / `No`) 
- **File:** `studep_rf_model.R` — includes preprocessing, model training, and evaluation  

---

## 💻 User Experience

Visit this repository to:

- 📁 Explore the model code and dataset
- 🧪 Test the model using mock data
- ⚙️ Access API-ready endpoints for integration (coming soon)
- 📘 Read about ethical considerations and limitations

The project also includes:

- Visual walkthroughs (feature plots, model logic diagrams)  
- A quick-start notebook for institutions to test on local data  
- Documentation with examples for R users

---

## 🎯 Use Cases

- **Universities**: Integrate into wellness surveys or orientation sessions to flag at-risk students.
- **Counselors**: Use as a decision-support tool alongside interviews.
- **Researchers**: Study patterns of mental health in student populations.
- **NGOs/Policy Makers**: Analyze trends in youth wellness and target resources effectively.

---

## ✅ How to Use

1. Clone this repository  
2. Run `studep_rf_model.R` in RStudio  
3. Use your own student dataset or the sample CSV provided  
4. View predictions and feature insights  

---

## ⚠️ Ethical Note

This model is not a diagnostic tool. It is designed to **support and inform**, not to replace clinical evaluation. Use responsibly and ensure student privacy and consent are respected.

---

## 📎 Files Included

| File | Description |
|------|-------------|
| `student_depression_dataset.csv` | Input dataset |
| `studep_rf_model.R` | Model training + evaluation code |
| `README.md` | Project overview and instructions |

---

## 📫 Contact

For feedback, collaboration, or deployment support, reach out via GitHub or [gokulvaratharasan@gmail.com].

---

> _Let’s make mental health support more proactive, data-driven, and compassionate._

