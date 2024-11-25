FROM tensorflow/tensorflow:latest

# Install Jupyter Notebook
RUN pip install notebook

# Expose the Jupyter port
EXPOSE 8888

# Run Jupyter Notebook by default
CMD ["jupyter", "notebook", "--ip=0.0.0.0", "--allow-root", "--no-browser"]
