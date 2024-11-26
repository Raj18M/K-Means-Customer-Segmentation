# **Customer Segmentation Using K-Means Clustering**

## Overview
This Shiny app is a powerful tool for customer segmentation, leveraging the K-Means clustering algorithm. Designed for retail store data, it enables users to explore transactional datasets, uncover hidden customer patterns, and derive actionable business insights. With an intuitive interface and robust backend, the app processes customer data efficiently to deliver meaningful visualizations and summaries.

## Key Features
- Interactive Data Upload: Supports CSV and Excel file formats for easy data upload.
- Data Preprocessing: Automatically filters invalid transactions, calculates total spending, and handles missing data.
- Dynamic Clustering: Allows users to specify the number of clusters (k) for K-Means analysis.
## Visual Insights:
- Scatter plot visualizing customer segmentation based on spending and purchase quantity.
- Bar plots showcasing the top items in each cluster for better inventory insights.
- Cluster Summaries: Generates detailed tables summarizing key metrics for each customer cluster, such as:
- Average purchase quantity and total spending.
- Count of unique items purchased.
- Number of customers in each cluster.
- Performance Optimization: Utilizes parallel processing for faster computations, ensuring a smooth experience even with large datasets.

## Getting Started
1. ### Prerequisites

Before running the app, ensure you have the following installed:

  R (version 4.0 or higher)
  RStudio (optional but recommended)
  Required R packages:

**`install.packages(c("shiny", "shinythemes", "readxl", "ggplot2", "dplyr", "DT", "parallel"))`**

2. ### Running the App

Clone this repository to your local machine:
**git clone https://github.com/Raj18M/K-Means-Customer-Segmentation.git**
Navigate to the app directory:
**`cd K-Means-Customer-Segmentation`
Launch the app in R or RStudio:
`runApp()`**
Open the app in your browser and follow the instructions to upload your dataset and analyze it.

3. ### Usage Instructions

    3.1. Upload Dataset
Click "Upload Dataset" and select a valid CSV or Excel file.
Ensure the dataset contains fields like Quantity, UnitPrice, and StockCode.

    3.2. Set Clustering Parameters

   3.3. Choose the number of clusters (k) using the input box.
 
   3.4. Click the "Run K-Means" button to perform the clustering.
  
4. ### Explore Results
  - Data Preview: View the uploaded data in tabular format.
  - Summary Statistics: Examine basic statistics for the dataset.
  - Clustering Results:
    - View scatter plots of clusters.
    - Analyze top items in each cluster through bar plots.
  - Review cluster-specific metrics in the summary table.

5. ### Input File Requirements

The uploaded dataset should contain the following columns:

- Quantity (Number of items purchased per transaction)
- UnitPrice (Price per unit of each item)
- StockCode (Unique identifier for each item)
- Optional: Additional columns can be included but are not required.

6. ### Outputs

- Scatter Plot: Visualizes customer clusters based on total spending and quantity purchased.
- Bar Plot: Displays the top 5 items for each cluster based on frequency.
- Summary Table: Provides average metrics, cluster sizes, and item diversity within each cluster.

7. ### Screenshots

 7.1. Main Dashboard
   
The app interface showing the uploaded data and controls is as follows:

![custseg](https://github.com/user-attachments/assets/8071cd1b-711e-43c4-97b7-8e682b8db674)


 7.2. Clustering Visualizations

Scatter plot image shows the segmented clusters.

![custseg2](https://github.com/user-attachments/assets/3997fe9b-eed8-4c7d-8ead-c5f65e04a33a)

 7.3. Cluster Summary

The summary table displays cluster-level metrics.

![cust](https://github.com/user-attachments/assets/7a8c83d6-26ea-4ac6-8a76-3cf305d78837)

8. ### Performance Optimization

This app is optimized for efficiency by utilizing parallel processing via the parallel package, enabling faster computations even with large datasets. The number of cores used is automatically adjusted based on the system's available resources.

9. ### Contributing

Contributions are welcome! If you encounter issues or have suggestions for improvement:

Fork this repository.
Create a new branch: git checkout -b feature-branch-name.
Commit your changes: git commit -m "Your detailed message".
Push to the branch: git push origin feature-branch-name.
Open a pull request.

10. ### License

This project is licensed under the MIT License. See the LICENSE file for details.

11. Acknowledgments

Packages Used: `shiny, shinythemes, readxl, ggplot2, dplyr, DT, parallel`.

Inspired by the growing need for data-driven insights in retail customer behavior.
