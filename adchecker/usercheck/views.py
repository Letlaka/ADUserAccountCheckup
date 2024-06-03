import subprocess
from django.shortcuts import render
from .forms import UserCheckForm
import os
import subprocess


def check_user(request):
    result = None
    if request.method == "POST":
        form = UserCheckForm(request.POST)
        if form.is_valid():
            username = form.cleaned_data["username"]
            result = run_powershell_script(username)
    else:
        form = UserCheckForm()
    context = {
        "form": form, 
        "result": result,
        "title":"CheckUser"
               }
    return render(request, "usercheck/check_user.html", context)


def run_powershell_script(username):
    # Get the absolute path of the directory containing the Django manage.py file
    base_dir = os.path.dirname(os.path.abspath(__file__))

    # Construct the path to your PowerShell script relative to the base directory
    script_path = os.path.join(base_dir, "ADUserCheck.ps1")

    # Construct the command to execute the PowerShell script
    cmd = [
        "powershell",
        "-ExecutionPolicy",
        "Unrestricted",
        "-File",
        script_path,
        username,
    ]

    # Run the PowerShell script and capture the output
    result = subprocess.run(cmd, capture_output=True, text=True)

    # Return the output of the PowerShell script
    return result.stdout
