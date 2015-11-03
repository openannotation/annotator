from flask import Flask, render_template, request, json, session, flash, redirect, url_for, make_response
from forms import SignUpForm, SignInForm
from models import db
from demoAnnotator import app
from models import User


# define root and corresponding request handler
@app.route("/",methods=['POST','GET'])
def main():
    
    if 'email' in request.cookies:
        print 'DEBUG:' + str(request.cookies['email'])
    else: 
        print 'DEUBG:' + str(request.cookies)
    
    return render_template('index.html')


@app.route('/signUp',methods=['POST','GET'])
def signUp():
    
    form = SignUpForm()
    currEmail = request.cookies.get('email')

    if currEmail:
        return redirect(url_for('main'))

    if form.validate() == False:
        return render_template('signup.html', form=form)
    else:   
        newuser = User(form.name.data, form.email.data, form.password.data)
        db.session.add(newuser)
        db.session.commit()

        response = make_response(redirect(url_for('main')))
        response.set_cookie('email', form.email.data)

        session['email'] = form.email.data
        
        return response
        #return redirect(url_for('main'))


@app.route('/signIn', methods=['POST','GET'])
def signIn():
    form = SignInForm()

    if 'email' in request.cookies:
        print 'DEBUG - signIn 1:' + str(request.cookies['email'])
    

    if 'email' in session:
        return redirect(url_for('main'))
   

    if form.validate() == False:
        return render_template('signin.html', form=form)
    else:

        session['email'] = form.email.data

        response = make_response(redirect(url_for('main')))  
        response.set_cookie('email',form.email.data)

        if 'email' in request.cookies:
            print 'DEBUG - signIn 2:' + str(request.cookies['email'])

        return response
        #return redirect(url_for('main'))


@app.route('/signOut')
def signOut():
 
    if 'email' not in session:
        return redirect(url_for('signIn'))

    response = make_response(redirect(url_for('main')))
    response.set_cookie('email', '', expires=0)
    session.pop('email', None)
    
    return response
    #return redirect(url_for('main'))





