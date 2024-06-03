from django import forms

class UserCheckForm(forms.Form):
    username = forms.CharField(label='Username', max_length=100)
