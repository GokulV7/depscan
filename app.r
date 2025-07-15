library(shiny)
library(httr)
library(jsonlite)

# Remove these lines - they're causing conflicts
# library(flexdashboard)
# library(shinydashboard)

# Choices for dropdowns
city_choices <- c("Ahmedabad", "Bangalore", "Bhopal", "Chennai", "Delhi", "Faridabad", "Ghaziabad", "Hyderabad", "Indore", "Jaipur", "Kalyan", "Kanpur", "Khaziabad", "Kolkata", "Lucknow", "Ludhiana", "Meerut", "Mumbai", "Nagpur", "Nashik", "Patna", "Pune", "Rajkot", "Srinagar", "Surat", "Thane", "Unknown", "Vadodara", "Varanasi", "Vasai-Virar", "Visakhapatnam")
profession_choices <- c("Content Writer", "Digital Marketer", "Educational Consultant", "UX/UI Designer", "Architect", "Chef", "Doctor", "Entrepreneur", "Lawyer", "Manager", "Pharmacist", "Student", "Teacher")
sleep_choices <- c("7-8 hours", "Less than 5 hours", "More than 8 hours", "Others")
diet_choices <- c("Moderate", "Others", "Unhealthy")
degree_choices <- c("B.Arch", "B.Com", "B.Ed", "B.Pharm", "B.Tech", "BA", "BBA", "BCA", "BE", "BHM", "BSc", "LLB", "LLM", "M.Com", "M.Ed", "M.Pharm", "M.Tech", "MA", "MBA", "MBBS", "MCA", "MD", "ME", "MHM", "MSc", "Others", "PhD")

ui <- fluidPage(
  tags$head(
    tags$style(HTML("
      @import url('https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700;800&display=swap');
      
      * {
        box-sizing: border-box;
      }
      
      html {
        scroll-behavior: smooth;
      }
      
      body {
        font-family: 'Poppins', sans-serif;
        background: linear-gradient(135deg, #667eea 0%, #764ba2 50%, #667eea 100%);
        background-size: 400% 400%;
        animation: gradientShift 15s ease infinite;
        margin: 0;
        padding: 10px;
        min-height: 100vh;
        overflow-x: hidden;
      }
      
      @keyframes gradientShift {
        0% { background-position: 0% 50%; }
        50% { background-position: 100% 50%; }
        100% { background-position: 0% 50%; }
      }
      
      .main-container {
        background: rgba(255, 255, 255, 0.98);
        border-radius: 30px;
        padding: 20px;
        margin: 0 auto;
        max-width: 1400px;
        box-shadow: 
          0 25px 50px rgba(0,0,0,0.15),
          0 0 0 1px rgba(255,255,255,0.5);
        backdrop-filter: blur(20px);
        border: 1px solid rgba(255,255,255,0.3);
        position: relative;
        animation: containerFadeIn 1s ease-out;
        /* IMPORTANT: Allow dropdowns to extend outside */
        overflow: visible !important;
      }
      
      @keyframes containerFadeIn {
        from { 
          opacity: 0; 
          transform: translateY(30px) scale(0.95); 
        }
        to { 
          opacity: 1; 
          transform: translateY(0) scale(1); 
        }
      }
      
      .main-container::before {
        content: '';
        position: absolute;
        top: 0;
        left: 0;
        right: 0;
        bottom: 0;
        background: radial-gradient(circle at 30% 20%, rgba(102, 126, 234, 0.1) 0%, transparent 50%),
                    radial-gradient(circle at 80% 80%, rgba(118, 75, 162, 0.1) 0%, transparent 50%);
        pointer-events: none;
      }
      
      .app-header {
        text-align: center;
        margin-bottom: 40px;
        padding: 40px;
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        border-radius: 25px;
        color: white;
        position: relative;
        overflow: hidden;
        box-shadow: 
          0 20px 40px rgba(102, 126, 234, 0.3),
          inset 0 1px 0 rgba(255,255,255,0.2);
        transform: perspective(1000px) rotateX(2deg);
        animation: headerFloat 6s ease-in-out infinite;
      }
      
      @keyframes headerFloat {
        0%, 100% { transform: perspective(1000px) rotateX(2deg) translateY(0px); }
        50% { transform: perspective(1000px) rotateX(2deg) translateY(-10px); }
      }
      
      .app-header::before {
        content: '';
        position: absolute;
        top: -50%;
        left: -50%;
        width: 200%;
        height: 200%;
        background: 
          radial-gradient(circle, rgba(255,255,255,0.15) 0%, transparent 70%),
          linear-gradient(45deg, transparent 0%, rgba(255,255,255,0.1) 50%, transparent 100%);
        animation: headerShimmer 8s ease-in-out infinite;
      }
      
      @keyframes headerShimmer {
        0%, 100% { transform: rotate(0deg) scale(1); opacity: 0.3; }
        50% { transform: rotate(180deg) scale(1.1); opacity: 0.1; }
      }
      
      .app-title {
        font-size: 3em;
        font-weight: 800;
        margin: 0;
        position: relative;
        z-index: 1;
        text-shadow: 2px 2px 4px rgba(0,0,0,0.2);
        animation: titlePulse 4s ease-in-out infinite;
      }
      
      @keyframes titlePulse {
        0%, 100% { transform: scale(1); }
        50% { transform: scale(1.05); }
      }
      
      .app-subtitle {
        font-size: 1.2em;
        margin: 15px 0 0 0;
        opacity: 0.95;
        position: relative;
        z-index: 1;
        font-weight: 500;
        animation: subtitleSlide 1s ease-out 0.5s both;
      }
      
      @keyframes subtitleSlide {
        from { opacity: 0; transform: translateY(20px); }
        to { opacity: 0.95; transform: translateY(0); }
      }
      
      /* CRITICAL FIXES FOR DROPDOWN OVERLAPPING */
      .input-section {
        background: linear-gradient(145deg, #ffffff 0%, #f8f9ff 100%);
        border-radius: 25px;
        padding: 30px;
        margin-bottom: 80px; /* Increased from 50px to 80px */
        box-shadow: 
          0 10px 30px rgba(0,0,0,0.08),
          0 1px 8px rgba(0,0,0,0.05);
        border: 1px solid rgba(102, 126, 234, 0.1);
        transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
        position: relative;
        animation: sectionSlideIn 0.8s ease-out both;
        /* CRITICAL: Allow dropdowns to extend outside */
        overflow: visible !important;
        z-index: 1;
      }
      
      /* Higher z-index when dropdown is active */
      .input-section:focus-within {
        z-index: 999 !important;
        overflow: visible !important;
      }
      
      .input-section:nth-child(1) { animation-delay: 0.1s; }
      .input-section:nth-child(2) { animation-delay: 0.2s; }
      .input-section:nth-child(3) { animation-delay: 0.3s; }
      .input-section:nth-child(4) { animation-delay: 0.4s; }
      
      @keyframes sectionSlideIn {
        from { 
          opacity: 0; 
          transform: translateY(40px) rotateX(10deg); 
        }
        to { 
          opacity: 1; 
          transform: translateY(0) rotateX(0deg); 
        }
      }
      
      .input-section::before {
        content: '';
        position: absolute;
        top: 0;
        left: -100%;
        width: 100%;
        height: 100%;
        background: linear-gradient(90deg, transparent, rgba(102, 126, 234, 0.1), transparent);
        transition: left 0.6s ease;
        pointer-events: none;
      }
      
      .input-section:hover {
        transform: translateY(-8px) scale(1.02);
        box-shadow: 
          0 20px 60px rgba(0,0,0,0.15),
          0 5px 20px rgba(102, 126, 234, 0.2);
        border-color: rgba(102, 126, 234, 0.3);
      }
      
      .input-section:hover::before {
        left: 100%;
      }
      
      .section-title {
        color: #4a5568;
        font-size: 1.4em;
        font-weight: 700;
        margin-bottom: 25px;
        display: flex;
        align-items: center;
        gap: 12px;
        position: relative;
        padding-bottom: 10px;
      }
      
      .section-title::after {
        content: '';
        position: absolute;
        bottom: 0;
        left: 0;
        width: 50px;
        height: 3px;
        background: linear-gradient(90deg, #667eea, #764ba2);
        border-radius: 2px;
        transition: width 0.3s ease;
      }
      
      .input-section:hover .section-title::after {
        width: 100px;
      }
      
      .form-group {
        margin-bottom: 35px; /* Increased from 30px */
        opacity: 0;
        animation: inputFadeIn 0.6s ease-out 0.3s both;
        position: relative;
        /* CRITICAL: Ensure dropdowns can extend */
        overflow: visible !important;
        z-index: 100;
      }
      
      /* Higher z-index when select is focused */
      .form-group:focus-within {
        z-index: 1000 !important;
        overflow: visible !important;
      }
      
      @keyframes inputFadeIn {
        from { opacity: 0; transform: translateX(-20px); }
        to { opacity: 1; transform: translateX(0); }
      }
      
      .form-group label {
        color: #2d3748;
        font-weight: 600;
        margin-bottom: 12px; /* Increased margin */
        display: block;
        font-size: 0.95em;
        transition: color 0.3s ease;
      }
      
      /* COMPLETELY REWRITTEN DROPDOWN STYLES TO FIX OVERLAPPING */
      .shiny-input-container {
        position: relative !important;
        overflow: visible !important;
        z-index: 100 !important;
      }
      
      .shiny-input-container:focus-within {
        z-index: 1001 !important;
      }
      
      select.form-control {
        border-radius: 15px !important;
        border: 2px solid #e2e8f0 !important;
        padding: 15px 20px !important;
        transition: all 0.3s ease !important;
        background: white !important;
        font-size: 16px !important;
        box-shadow: 0 2px 8px rgba(0,0,0,0.05) !important;
        cursor: pointer !important;
        min-height: 55px !important;
        width: 100% !important;
        position: relative !important;
        z-index: 100 !important;
        
        /* CRITICAL: Allow native dropdown to extend outside */
        appearance: auto !important;
        -webkit-appearance: auto !important;
        -moz-appearance: auto !important;
      }
      
      /* When dropdown is opened/focused */
      select.form-control:focus {
        border-color: #667eea !important;
        box-shadow: 
          0 0 0 4px rgba(102, 126, 234, 0.15) !important,
          0 4px 20px rgba(102, 126, 234, 0.2) !important;
        transform: translateY(-2px) !important;
        outline: none !important;
        z-index: 1001 !important;
        position: relative !important;
      }
      
      select.form-control:hover {
        border-color: #cbd5e0 !important;
        transform: translateY(-1px) !important;
        box-shadow: 0 4px 15px rgba(0,0,0,0.1) !important;
      }
      
      /* Enhanced option styling */
      select.form-control option {
        padding: 15px 20px !important; /* Increased padding */
        background: white !important;
        color: #2d3748 !important;
        font-size: 16px !important;
        line-height: 1.5 !important;
        border: none !important;
        min-height: 45px !important; /* Minimum height for better visibility */
      }
      
      /* Highlight selected option */
      select.form-control option:checked {
        background: #667eea !important;
        color: white !important;
        font-weight: 600 !important;
      }
      
      /* Hover effect for options */
      select.form-control option:hover {
        background: rgba(102, 126, 234, 0.1) !important;
        color: #667eea !important;
      }
      
      .form-control:not(select) {
        border-radius: 15px !important;
        border: 2px solid #e2e8f0 !important;
        padding: 15px 20px !important;
        transition: all 0.3s ease !important;
        background: white !important;
        font-size: 16px !important;
        box-shadow: 0 2px 8px rgba(0,0,0,0.05) !important;
      }
      
      .form-control:not(select):focus {
        border-color: #667eea !important;
        box-shadow: 
          0 0 0 4px rgba(102, 126, 234, 0.15) !important,
          0 4px 20px rgba(102, 126, 234, 0.2) !important;
        transform: translateY(-2px) !important;
        outline: none !important;
      }
      
      /* Ensure fluidRow and columns don't clip dropdowns */
      .row {
        overflow: visible !important;
      }
      
      .col-sm-6 {
        overflow: visible !important;
      }
      
      .predict-btn {
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        border: none;
        border-radius: 20px;
        padding: 18px 40px;
        color: white;
        font-weight: 700;
        font-size: 1.2em;
        width: 100%;
        cursor: pointer;
        transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
        box-shadow: 
          0 10px 30px rgba(102, 126, 234, 0.4),
          inset 0 1px 0 rgba(255,255,255,0.2);
        position: relative;
        overflow: hidden;
        text-transform: uppercase;
        letter-spacing: 1px;
        margin-top: 20px; /* Add some space above button */
      }
      
      .predict-btn::before {
        content: '';
        position: absolute;
        top: 0;
        left: -100%;
        width: 100%;
        height: 100%;
        background: linear-gradient(90deg, transparent, rgba(255,255,255,0.2), transparent);
        transition: left 0.6s ease;
        pointer-events: none;
      }
      
      .predict-btn:hover {
        transform: translateY(-4px) scale(1.02);
        box-shadow: 
          0 15px 40px rgba(102, 126, 234, 0.5),
          0 5px 20px rgba(102, 126, 234, 0.3);
        background: linear-gradient(135deg, #7c89f0 0%, #8662c7 100%);
      }
      
      .predict-btn:hover::before {
        left: 100%;
      }
      
      .predict-btn:active {
        transform: translateY(-2px) scale(0.98);
      }
      
      .battery-container {
        display: flex;
        flex-direction: column;
        align-items: center;
        margin: 40px 0;
        animation: batteryEntrance 1s ease-out;
      }
      
      @keyframes batteryEntrance {
        from { 
          opacity: 0; 
          transform: scale(0.8) rotate(5deg); 
        }
        to { 
          opacity: 1; 
          transform: scale(1) rotate(0deg); 
        }
      }
      
      .battery {
        width: 90px;
        height: 220px;
        border: 5px solid #e2e8f0;
        border-radius: 15px;
        position: relative;
        background: linear-gradient(145deg, #f7fafc, #edf2f7);
        overflow: hidden;
        box-shadow: 
          inset 0 4px 15px rgba(0,0,0,0.1),
          0 8px 25px rgba(0,0,0,0.15);
        transition: all 0.3s ease;
      }
      
      .battery:hover {
        transform: scale(1.05);
        box-shadow: 
          inset 0 4px 15px rgba(0,0,0,0.15),
          0 12px 35px rgba(0,0,0,0.2);
      }
      
      .battery::before {
        content: '';
        position: absolute;
        top: -10px;
        left: 50%;
        transform: translateX(-50%);
        width: 25px;
        height: 10px;
        background: linear-gradient(145deg, #e2e8f0, #cbd5e0);
        border-radius: 5px 5px 0 0;
        box-shadow: inset 0 1px 3px rgba(0,0,0,0.2);
      }
      
      .battery-fill {
        position: absolute;
        bottom: 0;
        left: 0;
        right: 0;
        border-radius: 10px;
        transition: all 1.5s cubic-bezier(0.4, 0, 0.2, 1);
        background: linear-gradient(to top, 
          #22c55e 0%, 
          #22c55e 20%, 
          #eab308 20%, 
          #eab308 40%, 
          #f97316 40%, 
          #f97316 60%, 
          #ef4444 60%, 
          #ef4444 80%, 
          #dc2626 80%, 
          #dc2626 100%);
        box-shadow: 
          0 0 20px rgba(34, 197, 94, 0.5),
          inset 0 2px 10px rgba(255,255,255,0.2);
        animation: batteryPulse 2s ease-in-out infinite;
      }
      
      @keyframes batteryPulse {
        0%, 100% { 
          box-shadow: 
            0 0 20px rgba(34, 197, 94, 0.5),
            inset 0 2px 10px rgba(255,255,255,0.2);
        }
        50% { 
          box-shadow: 
            0 0 30px rgba(34, 197, 94, 0.8),
            inset 0 2px 10px rgba(255,255,255,0.3);
        }
      }
      
      .battery-percentage {
        position: absolute;
        top: 50%;
        left: 50%;
        transform: translate(-50%, -50%);
        font-weight: 800;
        font-size: 16px;
        color: white;
        text-shadow: 2px 2px 4px rgba(0,0,0,0.7);
        z-index: 2;
        animation: percentageBounce 1s ease-out 0.5s both;
      }
      
      @keyframes percentageBounce {
        from { 
          opacity: 0; 
          transform: translate(-50%, -50%) scale(0.5); 
        }
        60% { 
          transform: translate(-50%, -50%) scale(1.2); 
        }
        to { 
          opacity: 1; 
          transform: translate(-50%, -50%) scale(1); 
        }
      }
      
      .result-container {
        background: linear-gradient(145deg, #ffffff 0%, #f8f9ff 100%);
        border-radius: 30px;
        padding: 40px;
        box-shadow: 
          0 20px 60px rgba(0,0,0,0.12),
          0 8px 30px rgba(102, 126, 234, 0.1);
        border: 1px solid rgba(102, 126, 234, 0.1);
        text-align: center;
        position: relative;
        overflow: hidden;
        animation: resultEntrance 0.8s cubic-bezier(0.4, 0, 0.2, 1) both;
      }
      
      @keyframes resultEntrance {
        from { 
          opacity: 0; 
          transform: translateY(40px) scale(0.95) rotateX(10deg); 
        }
        to { 
          opacity: 1; 
          transform: translateY(0) scale(1) rotateX(0deg); 
        }
      }
      
      .result-container::before {
        content: '';
        position: absolute;
        top: 0;
        left: 0;
        right: 0;
        height: 6px;
        background: linear-gradient(90deg, #667eea 0%, #764ba2 100%);
        border-radius: 30px 30px 0 0;
      }
      
      .level-minimal { 
        background: linear-gradient(135deg, #dcfce7 0%, #bbf7d0 100%);
        border-left: 6px solid #22c55e;
        animation: levelGlow 2s ease-in-out infinite;
      }
      .level-mild { 
        background: linear-gradient(135deg, #fefce8 0%, #fef3c7 100%);
        border-left: 6px solid #eab308;
        animation: levelGlow 2s ease-in-out infinite;
      }
      .level-moderate { 
        background: linear-gradient(135deg, #fff7ed 0%, #fed7aa 100%);
        border-left: 6px solid #f97316;
        animation: levelGlow 2s ease-in-out infinite;
      }
      .level-severe { 
        background: linear-gradient(135deg, #fef2f2 0%, #fecaca 100%);
        border-left: 6px solid #ef4444;
        animation: levelGlow 2s ease-in-out infinite;
      }
      .level-critical { 
        background: linear-gradient(135deg, #faf5ff 0%, #e9d5ff 100%);
        border-left: 6px solid #dc2626;
        animation: levelGlow 2s ease-in-out infinite;
      }
      
      @keyframes levelGlow {
        0%, 100% { box-shadow: 0 20px 60px rgba(0,0,0,0.12); }
        50% { box-shadow: 0 25px 70px rgba(0,0,0,0.18); }
      }
      
      .score-display {
        font-size: 4.5em;
        font-weight: 800;
        margin: 25px 0;
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        -webkit-background-clip: text;
        -webkit-text-fill-color: transparent;
        background-clip: text;
        animation: scoreCountUp 2s ease-out;
        text-shadow: 0 0 30px rgba(102, 126, 234, 0.5);
      }
      
      @keyframes scoreCountUp {
        from { 
          transform: scale(0.5) rotate(-10deg); 
          opacity: 0; 
        }
        60% { 
          transform: scale(1.1) rotate(2deg); 
        }
        to { 
          transform: scale(1) rotate(0deg); 
          opacity: 1; 
        }
      }
      
      .level-badge {
        display: inline-block;
        padding: 15px 30px;
        border-radius: 30px;
        font-weight: 700;
        text-transform: uppercase;
        letter-spacing: 2px;
        margin: 20px 0;
        box-shadow: 0 8px 25px rgba(0,0,0,0.2);
        transition: all 0.3s ease;
        animation: badgeSlideIn 0.8s ease-out 0.5s both;
      }
      
      @keyframes badgeSlideIn {
        from { 
          opacity: 0; 
          transform: translateY(20px) scale(0.8); 
        }
        to { 
          opacity: 1; 
          transform: translateY(0) scale(1); 
        }
      }
      
      .level-badge:hover {
        transform: scale(1.05);
        box-shadow: 0 12px 35px rgba(0,0,0,0.3);
      }
      
      .description-text {
        font-size: 1.3em;
        color: #4a5568;
        margin: 25px 0;
        line-height: 1.8;
        animation: textSlideIn 0.8s ease-out 0.7s both;
      }
      
      @keyframes textSlideIn {
        from { 
          opacity: 0; 
          transform: translateY(20px); 
        }
        to { 
          opacity: 1; 
          transform: translateY(0); 
        }
      }
      
      .recommendation-box {
        background: rgba(102, 126, 234, 0.1);
        border-radius: 20px;
        padding: 25px;
        margin-top: 30px;
        border-left: 5px solid #667eea;
        transition: all 0.3s ease;
        animation: recommendationSlideIn 0.8s ease-out 0.9s both;
      }
      
      @keyframes recommendationSlideIn {
        from { 
          opacity: 0; 
          transform: translateX(-30px); 
        }
        to { 
          opacity: 1; 
          transform: translateX(0); 
        }
      }
      
      .recommendation-box:hover {
        background: rgba(102, 126, 234, 0.15);
        transform: translateY(-3px);
        box-shadow: 0 10px 30px rgba(102, 126, 234, 0.2);
      }
      
      .recommendation-title {
        color: #667eea;
        font-weight: 700;
        margin-bottom: 15px;
        font-size: 1.2em;
      }
      
      .loading-spinner {
        display: inline-block;
        width: 50px;
        height: 50px;
        border: 5px solid #f3f3f3;
        border-top: 5px solid #667eea;
        border-radius: 50%;
        animation: spin 1s linear infinite, pulse 2s ease-in-out infinite;
        margin: 25px 0;
      }
      
      @keyframes spin {
        0% { transform: rotate(0deg); }
        100% { transform: rotate(360deg); }
      }
      
      @keyframes pulse {
        0%, 100% { 
          box-shadow: 0 0 20px rgba(102, 126, 234, 0.3); 
        }
        50% { 
          box-shadow: 0 0 40px rgba(102, 126, 234, 0.6); 
        }
      }
      
      .welcome-icon {
        font-size: 5em;
        margin: 25px 0;
        opacity: 0.8;
        animation: iconFloat 3s ease-in-out infinite;
      }
      
      @keyframes iconFloat {
        0%, 100% { transform: translateY(0px) rotate(0deg); }
        50% { transform: translateY(-10px) rotate(5deg); }
      }
      
      .fade-in {
        animation: fadeIn 0.8s ease-in;
      }
      
      @keyframes fadeIn {
        from { 
          opacity: 0; 
          transform: translateY(30px) scale(0.95); 
        }
        to { 
          opacity: 1; 
          transform: translateY(0) scale(1); 
        }
      }
      
      .model-info-section {
        background: linear-gradient(145deg, #f8fafc 0%, #f1f5f9 100%);
        border-radius: 30px;
        padding: 40px;
        margin: 40px 0;
        box-shadow: 
          0 15px 50px rgba(0,0,0,0.1),
          0 5px 20px rgba(71, 85, 105, 0.05);
        border: 1px solid rgba(71, 85, 105, 0.1);
        animation: modelSectionSlideIn 1s ease-out both;
      }
      
      @keyframes modelSectionSlideIn {
        from { 
          opacity: 0; 
          transform: translateY(50px) rotateX(10deg); 
        }
        to { 
          opacity: 1; 
          transform: translateY(0) rotateX(0deg); 
        }
      }
      
      .model-info-title {
        color: #1e293b;
        font-size: 2em;
        font-weight: 800;
        margin-bottom: 30px;
        text-align: center;
        display: flex;
        align-items: center;
        justify-content: center;
        gap: 20px;
        animation: titleSlideIn 0.8s ease-out 0.3s both;
      }
      
      @keyframes titleSlideIn {
        from { 
          opacity: 0; 
          transform: translateY(-20px); 
        }
        to { 
          opacity: 1; 
          transform: translateY(0); 
        }
      }
      
      .model-stats-grid {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
        gap: 25px;
        margin: 35px 0;
      }
      
      .stat-card {
        background: white;
        border-radius: 20px;
        padding: 30px;
        text-align: center;
        box-shadow: 
          0 8px 25px rgba(0,0,0,0.1),
          0 2px 10px rgba(0,0,0,0.05);
        border-left: 5px solid #667eea;
        transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
        position: relative;
        overflow: hidden;
        animation: statCardSlideIn 0.6s ease-out both;
      }
      
      .stat-card:nth-child(1) { animation-delay: 0.1s; }
      .stat-card:nth-child(2) { animation-delay: 0.2s; }
      .stat-card:nth-child(3) { animation-delay: 0.3s; }
      .stat-card:nth-child(4) { animation-delay: 0.4s; }
      
      @keyframes statCardSlideIn {
        from { 
          opacity: 0; 
          transform: translateY(30px) scale(0.9); 
        }
        to { 
          opacity: 1; 
          transform: translateY(0) scale(1); 
        }
      }
      
      .stat-card::before {
        content: '';
        position: absolute;
        top: 0;
        left: -100%;
        width: 100%;
        height: 100%;
        background: linear-gradient(90deg, transparent, rgba(102, 126, 234, 0.1), transparent);
        transition: left 0.6s ease;
      }
      
      .stat-card:hover {
        transform: translateY(-8px) scale(1.05);
        box-shadow: 
          0 20px 60px rgba(0,0,0,0.15),
          0 10px 30px rgba(102, 126, 234, 0.2);
        border-left-color: #764ba2;
      }
      
      .stat-card:hover::before {
        left: 100%;
      }
      
      .stat-value {
        font-size: 2.5em;
        font-weight: 800;
        color: #667eea;
        margin-bottom: 10px;
        animation: valueCountUp 1s ease-out;
      }
      
      @keyframes valueCountUp {
        from { 
          opacity: 0; 
          transform: scale(0.5) rotate(-5deg); 
        }
        to { 
          opacity: 1; 
          transform: scale(1) rotate(0deg); 
        }
      }
      
      .stat-label {
        color: #64748b;
        font-weight: 600;
        font-size: 1em;
        text-transform: uppercase;
        letter-spacing: 1px;
      }
      
      .model-details {
        background: white;
        border-radius: 20px;
        padding: 35px;
        margin-top: 25px;
        box-shadow: 
          0 8px 25px rgba(0,0,0,0.1),
          0 2px 10px rgba(0,0,0,0.05);
        animation: detailsSlideIn 0.8s ease-out 0.5s both;
      }
      
      @keyframes detailsSlideIn {
        from { 
          opacity: 0; 
          transform: translateX(-30px); 
        }
        to { 
          opacity: 1; 
          transform: translateX(0); 
        }
      }
      
      .model-details h4 {
        color: #1e293b;
        font-weight: 700;
        margin-bottom: 20px;
        border-bottom: 3px solid #e2e8f0;
        padding-bottom: 15px;
        position: relative;
      }
      
      .model-details h4::after {
        content: '';
        position: absolute;
        bottom: -3px;
        left: 0;
        width: 60px;
        height: 3px;
        background: linear-gradient(90deg, #667eea, #764ba2);
        border-radius: 2px;
      }
      
      .model-details p {
        color: #475569;
        line-height: 1.8;
        margin-bottom: 15px;
        font-size: 1.05em;
      }
      
      .reliability-badge {
        display: inline-block;
        background: linear-gradient(135deg, #10b981 0%, #059669 100%);
        color: white;
        padding: 10px 20px;
        border-radius: 25px;
        font-weight: 600;
        font-size: 0.95em;
        margin: 15px 8px 0 0;
        transition: all 0.3s ease;
        animation: badgePopIn 0.6s ease-out both;
      }
      
      .reliability-badge:nth-child(1) { animation-delay: 0.1s; }
      .reliability-badge:nth-child(2) { animation-delay: 0.2s; }
      .reliability-badge:nth-child(3) { animation-delay: 0.3s; }
      
      @keyframes badgePopIn {
        from { 
          opacity: 0; 
          transform: scale(0.8) rotate(-5deg); 
        }
        to { 
          opacity: 1; 
          transform: scale(1) rotate(0deg); 
        }
      }
      
      .reliability-badge:hover {
        transform: scale(1.05);
        box-shadow: 0 5px 20px rgba(16, 185, 129, 0.4);
      }
      
      .disclaimer {
        background: rgba(255, 193, 7, 0.15);
        border-radius: 20px;
        padding: 25px;
        margin-top: 40px;
        border-left: 5px solid #ffc107;
        color: #856404;
        font-weight: 500;
        box-shadow: 0 5px 20px rgba(255, 193, 7, 0.2);
        animation: disclaimerSlideIn 0.8s ease-out 0.7s both;
      }
      
      @keyframes disclaimerSlideIn {
        from { 
          opacity: 0; 
          transform: translateY(20px); 
        }
        to { 
          opacity: 1; 
          transform: translateY(0); 
        }
      }
      
      @media (max-width: 768px) {
        .main-container {
          padding: 15px;
          border-radius: 20px;
        }
        
        .app-header {
          padding: 25px;
          transform: none;
        }
        
        .app-title {
          font-size: 2.2em;
        }
        
        .input-section {
          padding: 20px;
          margin-bottom: 60px; /* Adjusted for mobile */
        }
        
        .model-stats-grid {
          grid-template-columns: 1fr;
          gap: 15px;
        }
        
        .battery {
          width: 70px;
          height: 180px;
        }
        
        .score-display {
          font-size: 3em;
        }
      }
    "))
  ),
  
  div(class = "main-container",
    div(class = "app-header",
      h1(class = "app-title", "🧠 DepScan"),
      p(class = "app-subtitle", "Machine Learning-Based Mental Health Assessment Tool")
    ),
    
    fluidRow(
      column(6,
        div(class = "input-section fade-in",
          h3(class = "section-title", "👤 Personal Information"),
          
          div(class = "form-group",
            selectInput("gender", "Gender:", 
                       choices = c("Female", "Male"),
                       selected = "Male")
          ),
          
          div(class = "form-group",
            numericInput("age", "Age:", 
                        value = 22, min = 16, max = 65, step = 1)
          ),
          
          div(class = "form-group",
            selectInput("city", "City:", 
                       choices = city_choices,
                       selected = "Delhi")
          ),
          
          div(class = "form-group",
            selectInput("profession", "Profession:", 
                       choices = profession_choices,
                       selected = "Student")
          )
        ),
        
        div(class = "input-section fade-in",
          h3(class = "section-title", "🎓 Academic & Work"),
          
          div(class = "form-group",
            sliderInput("academic_pressure", "Academic Pressure Level:",
                       min = 1, max = 5, value = 3, step = 1,
                       ticks = TRUE)
          ),
          
          div(class = "form-group",
            sliderInput("work_pressure", "Work Pressure Level:",
                       min = 0, max = 5, value = 1, step = 1,
                       ticks = TRUE)
          ),
          
          div(class = "form-group",
            numericInput("cgpa", "CGPA/Grade:", 
                        value = 7.5, min = 0, max = 10, step = 0.1)
          ),
          
          div(class = "form-group",
            sliderInput("study_satisfaction", "Study Satisfaction:",
                       min = 1, max = 5, value = 3, step = 1,
                       ticks = TRUE)
          )
        )
      ),
      
      column(6,
        div(class = "input-section fade-in",
          h3(class = "section-title", "🏠 Lifestyle & Health"),
          
          div(class = "form-group",
            selectInput("sleep", "Sleep Duration:", 
                       choices = sleep_choices,
                       selected = "7-8 hours")
          ),
          
          div(class = "form-group",
            selectInput("diet", "Dietary Habits:", 
                       choices = diet_choices,
                       selected = "Moderate")
          ),
          
          div(class = "form-group",
            selectInput("degree", "Degree:", 
                       choices = degree_choices,
                       selected = "BE")
          ),
          
          div(class = "form-group",
            sliderInput("financial_stress", "Financial Stress Level:",
                       min = 1, max = 5, value = 3, step = 1,
                       ticks = TRUE)
          ),
          
          div(class = "form-group",
            sliderInput("work_study_hours", "Daily Work/Study Hours:",
                       min = 1, max = 16, value = 8, step = 1,
                       ticks = TRUE)
          )
        ),
        
        div(class = "input-section fade-in",
          h3(class = "section-title", "🩺 Mental Health History"),
          
          div(class = "form-group",
            selectInput("suicidal", "Ever had suicidal thoughts?", 
                       choices = c("No", "Yes"),
                       selected = "No")
          ),
          
          div(class = "form-group",
            selectInput("family_history", "Family history of mental illness?", 
                       choices = c("No", "Yes"),
                       selected = "No")
          ),
          
          br(),
          actionButton("predict", "🔍 Analyze Depression Risk", 
                      class = "predict-btn")
        )
      )
    ),
    
    br(),
    
    fluidRow(
      column(12,
        uiOutput("resultPanel")
      )
    ),
    
    div(class = "model-info-section fade-in",
      h2(class = "model-info-title", "🤖 Model Performance & Metrics"),
      
      div(class = "model-stats-grid",
        div(class = "stat-card",
          div(class = "stat-value", "XGBoost"),
          div(class = "stat-label", "Algorithm Used")
        ),
        div(class = "stat-card",
          div(class = "stat-value", "84.3%"),
          div(class = "stat-label", "Test accuracy")
        ),
        div(class = "stat-card",
          div(class = "stat-value", "86.5%"),
          div(class = "stat-label", "Training Accuracy")
        ),
        div(class = "stat-card",
          div(class = "stat-value", "15"),
          div(class = "stat-label", "Features")
        )
      ),
      
      div(class = "model-details",
        h4("📊 About Our Model"),
        p("Our depression risk assessment model is built using ", strong("XGBoost (Extreme Gradient Boosting)"), 
          ", a powerful machine learning algorithm known for its high performance in prediction tasks."),
        
        h4("🎯 Model Performance"),
        p("• ", strong("Overall Test Accuracy: 84.3%"), " - Shows the model correctly predicts depression levels in 84.3% of test cases"),
        p("• ", strong("Training Accuracy: 86.5%"), " - Demonstrates excellent learning with minimal overfitting"),
        
        h4("📚 Training Data"),
        p("The model was trained on a comprehensive ", strong("student mental health survey dataset"), 
          " containing responses from diverse demographics, academic backgrounds, and lifestyle factors. ",
          "This ensures broad applicability across different student populations."),
        
        h4("🔍 Feature Analysis"),
        p("Our model analyzes ", strong("15 different features"), " including:"),
        p("• Personal demographics (age, gender, location)"),
        p("• Academic factors (pressure, satisfaction, performance)"),
        p("• Lifestyle indicators (sleep, diet, work hours)"),
        p("• Mental health history (family history, suicidal ideation)"),
        
        div(style = "margin-top: 20px;",
          span(class = "reliability-badge", "✓ Educational Tool"),
          span(class = "reliability-badge", "✓ Research-Based"),
          span(class = "reliability-badge", "✓ Survey-Based Data"),
          span(class = "reliability-badge", "✓ Validated Performance")
        )
      )
    ),
    
    div(class = "disclaimer",
    p("⚠️ ", strong("Important Disclaimer:"), " This tool is designed for educational and screening purposes only. It is ", strong("not a substitute for professional medical diagnosis or treatment."), " If you are experiencing mental health concerns, please consult a qualified healthcare professional, counselor, or contact a mental health helpline immediately.")
    )
  )
)

# Server code remains the same as before
server <- function(input, output) {
  
  createBatteryLevel <- function(percentage, level) {
    fill_height <- percentage
    
    level_colors <- list(
      "Minimal" = "#22c55e",
      "Mild" = "#eab308", 
      "Moderate" = "#f97316",
      "Severe" = "#ef4444",
      "Critical" = "#dc2626"
    )
    
    fill_color <- level_colors[[level]]
    
    div(class = "battery-container",
      div(class = "battery",
        div(class = "battery-fill", 
            style = paste0("height: ", fill_height, "%; background-color: ", fill_color, ";")),
        div(class = "battery-percentage", paste0(round(percentage), "%"))
      ),
      h4(paste("Depression Level:", level), style = paste0("color: ", fill_color, "; margin-top: 15px;"))
    )
  }
  
  observeEvent(input$predict, {
    
    output$resultPanel <- renderUI({
      div(class = "result-container fade-in",
        h3("🔄 Analyzing Your Mental Health Profile", style = "color: #667eea;"),
        div(class = "loading-spinner"),
        p("Processing your information using our trained statistical model...")
      )
    })
    
    api_input <- list(
      "GenderFemale" = ifelse(input$gender == "Female", 1, 0),
      "GenderMale" = ifelse(input$gender == "Male", 1, 0),
      "Age" = input$age,
      
      "CityAhmedabad" = 0, "CityBangalore" = 0, "CityBhopal" = 0, "CityChennai" = 0,
      "CityDelhi" = 0, "CityFaridabad" = 0, "CityGhaziabad" = 0, "CityHyderabad" = 0,
      "CityIndore" = 0, "CityJaipur" = 0, "CityKalyan" = 0, "CityKanpur" = 0,
      "CityKhaziabad" = 0, "CityKolkata" = 0, "CityLucknow" = 0, "CityLudhiana" = 0,
      "CityMeerut" = 0, "CityMumbai" = 0, "CityNagpur" = 0, "CityNashik" = 0,
      "CityPatna" = 0, "CityPune" = 0, "CityRajkot" = 0, "CitySrinagar" = 0,
      "CitySurat" = 0, "CityThane" = 0, "CityUnknown" = 0, "CityVadodara" = 0,
      "CityVaranasi" = 0, "CityVasai-Virar" = 0, "CityVisakhapatnam" = 0,
      
      "Profession'Content Writer'" = 0, "Profession'Digital Marketer'" = 0,
      "Profession'Educational Consultant'" = 0, "Profession'UX/UI Designer'" = 0,
      "ProfessionArchitect" = 0, "ProfessionChef" = 0, "ProfessionDoctor" = 0,
      "ProfessionEntrepreneur" = 0, "ProfessionLawyer" = 0, "ProfessionManager" = 0,
      "ProfessionPharmacist" = 0, "ProfessionStudent" = 0, "ProfessionTeacher" = 0,
      
      "`Academic Pressure`" = input$academic_pressure,
      "`Work Pressure`" = input$work_pressure,
      "CGPA" = input$cgpa,
      "`Study Satisfaction`" = input$study_satisfaction,
      "`Job Satisfaction`" = 0,
      
      "`Sleep Duration`7-8 hours" = 0,
      "`Sleep Duration`Less than 5 hours" = 0,
      "`Sleep Duration`More than 8 hours" = 0,
      "`Sleep Duration`Others" = 0,
      
      "`Dietary Habits`Moderate" = 0,
      "`Dietary Habits`Others" = 0,
      "`Dietary Habits`Unhealthy" = 0,
      
      "DegreeB.Arch" = 0, "DegreeB.Com" = 0, "DegreeB.Ed" = 0, "DegreeB.Pharm" = 0,
      "DegreeB.Tech" = 0, "DegreeBA" = 0, "DegreeBBA" = 0, "DegreeBCA" = 0,
      "DegreeBE" = 0, "DegreeBHM" = 0, "DegreeBSc" = 0, "DegreeLLB" = 0,
      "DegreeLLM" = 0, "DegreeM.Com" = 0, "DegreeM.Ed" = 0, "DegreeM.Pharm" = 0,
      "DegreeM.Tech" = 0, "DegreeMA" = 0, "DegreeMBA" = 0, "DegreeMBBS" = 0,
      "DegreeMCA" = 0, "DegreeMD" = 0, "DegreeME" = 0, "DegreeMHM" = 0,
      "DegreeMSc" = 0, "DegreeOthers" = 0, "DegreePhD" = 0,
      
      "`Have you ever had suicidal thoughts`Yes" = ifelse(input$suicidal == "Yes", 1, 0),
      "`Work Study Hours`" = input$work_study_hours,
      
      "`Financial Stress`1" = 0, "`Financial Stress`2" = 0, "`Financial Stress`3" = 0,
      "`Financial Stress`4" = 0, "`Financial Stress`5" = 0,
      
      "`Family History of Mental Illness`Yes" = ifelse(input$family_history == "Yes", 1, 0)
    )
    
    city_col <- paste0("City", input$city)
    if (city_col %in% names(api_input)) api_input[[city_col]] <- 1
    
    if (input$profession %in% c("Content Writer", "Digital Marketer", "Educational Consultant", "UX/UI Designer")) {
      prof_col <- paste0("Profession'", input$profession, "'")
    } else {
      prof_col <- paste0("Profession", gsub(" ", "", input$profession))
    }
    if (prof_col %in% names(api_input)) api_input[[prof_col]] <- 1
    
    sleep_col <- paste0("`Sleep Duration`", input$sleep)
    if (sleep_col %in% names(api_input)) api_input[[sleep_col]] <- 1
    
    diet_col <- paste0("`Dietary Habits`", input$diet)
    if (diet_col %in% names(api_input)) api_input[[diet_col]] <- 1
    
    degree_col <- paste0("Degree", gsub("\\.", "", input$degree))
    if (degree_col %in% names(api_input)) api_input[[degree_col]] <- 1
    
    financial_col <- paste0("`Financial Stress`", input$financial_stress)
    if (financial_col %in% names(api_input)) api_input[[financial_col]] <- 1
    
    tryCatch({
      api_input_list <- list(api_input)
      
      response <- POST(
        "https://gokulv7-depressionpredictor.hf.space/predict",
        body = toJSON(api_input_list, auto_unbox = TRUE),
        encode = "json",
        add_headers("Content-Type" = "application/json"),
        timeout(30)
      )
      
      if (status_code(response) == 200) {
        result <- fromJSON(content(response, "text", encoding = "UTF-8"))
        
        depression_score <- result$depression_score
        percentage <- result$percentage
        level <- result$level
        description <- result$description
        recommendation <- result$recommendation
        
        css_class <- paste0("level-", tolower(level))
        
        level_colors <- list(
          "Minimal" = "#22c55e",
          "Mild" = "#eab308", 
          "Moderate" = "#f97316",
          "Severe" = "#ef4444",
          "Critical" = "#dc2626"
        )
        
        level_color <- level_colors[[level]]
        percentage_numeric <- depression_score * 100
        
        output$resultPanel <- renderUI({
          div(class = paste("result-container", css_class, "fade-in"),
            h2("🎯 Your Mental Health Assessment", style = "color: #4a5568; margin-bottom: 30px;"),
            
            fluidRow(
              column(6,
                createBatteryLevel(percentage_numeric, level),
                div(class = "score-display", percentage),
                div(class = "level-badge", level,
                    style = paste0("background-color: ", level_color, "; color: white;"))
              ),
              column(6,
                h3("📋 Analysis Results", style = "color: #4a5568; margin-bottom: 20px;"),
                p(class = "description-text", description),
                
                div(class = "recommendation-box",
                  h4(class = "recommendation-title", "💡 Our Recommendation:"),
                  p(recommendation, style = "margin: 0; font-weight: 500; font-size: 1.1em;")
                )
              )
            )
          )
        })
        
      } else {
        output$resultPanel <- renderUI({
          div(class = "result-container level-severe fade-in",
            h3("❌ Connection Error", style = "color: #ef4444;"),
            p("Unable to connect to the prediction service. Please try again later."),
            div(class = "welcome-icon", "🔌")
          )
        })
      }
      
    }, error = function(e) {
      output$resultPanel <- renderUI({
        div(class = "result-container level-severe fade-in",
          h3("⚠️ Processing Error", style = "color: #ef4444;"),
          p("An error occurred during analysis. Please check your inputs and try again."),
          div(class = "welcome-icon", "⚠️")
        )
      })
    })
  })
  
  output$resultPanel <- renderUI({
    div(class = "result-container fade-in",
      h2("👋 Welcome to DepScan", style = "color: #4a5568;"),
      div(class = "welcome-icon", "🧠"),
      p("Complete the assessment form to receive your personalized mental health analysis.", 
        style = "font-size: 1.2em; color: #6b7280; margin: 20px 0;"),
      p("Our machine-learning model will evaluate various factors from your responses to provide depression risk insights and recommendations.", 
        style = "color: #9ca3af;"),
      p("Let’s make mental health support more proactive, data-driven, and compassionate 🫂!", 
        style = "color:rgb(61, 63, 67);")  
    )
  })
}

shinyApp(ui = ui, server = server)