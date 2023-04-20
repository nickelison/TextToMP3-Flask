from app import db, bcrypt
from models import Name, User
from users.forms import SignupForm, LoginForm, DeleteForm, ResetApiKeyForm, ResetPasswordForm, ProfilePictureForm
from flask import Blueprint, flash, current_app, render_template, url_for, redirect, request, jsonify
from flask_login import current_user, login_required, login_user, logout_user
import secrets
from users.utils import save_profile_picture
import boto3

users = Blueprint('users', __name__)


@users.route('/signup/', methods=['GET', 'POST'])
def signup():
    form = SignupForm()

    if form.validate_on_submit():
        api_key = secrets.token_urlsafe(43)

        hashed_password = bcrypt.generate_password_hash(form.password.data).decode('utf-8')
        user = User(username=form.username.data,
                    email=form.email.data,
                    password=hashed_password,
                    api_key=api_key)
        db.session.add(user)
        db.session.commit()
        logout_user()

        flash('Account created! Sign in!', 'success')
        return redirect(url_for('users.login'))

    return render_template('users/signup.html', title="Sign Up", form=form)


@users.route('/login/', methods=['GET', 'POST'])
def login():
    form = LoginForm()

    if current_user.is_authenticated:
        return redirect(url_for('main.index'))

    if form.validate_on_submit():
        user = User.query.filter_by(email=form.email.data).first()

        if not user:
            user = User.query.filter_by(username=form.email.data).first()

        if user and bcrypt.check_password_hash(user.password, form.password.data):
            login_user(user, remember=form.remember.data)
            next_page = request.args.get('next')
            if next_page:
                return redirect(next_page)
            else:
                return redirect(url_for('main.index'))
        else:
            flash('Login failed. Please check username and password.', 'danger')

    return render_template('users/login.html', title="Log In", form=form)


@users.route('/logout/', methods=['GET'])
@login_required
def logout():
    logout_user()
    return redirect(url_for('main.index'))


@users.route('/account/', methods=['GET', 'POST'])
@login_required
def account():
    # form = DeleteForm()
    user = User.query.filter_by(username=current_user.username).first_or_404()
    form = ProfilePictureForm()

    if form.validate_on_submit():
        if form.picture.data:
            current_user.profile_picture = save_profile_picture(form.picture.data)

        db.session.commit()
        flash("Your profile picture has been updated!", "success")
        return redirect(url_for('users.account'))

    # return render_template('users/account.html', user=user, form=form)
    return render_template('users/account.html', title='Account', user=user, form=form)


@users.route('/delete-account/', methods=['POST'])
@login_required
def delete_account():
    form = DeleteForm()

    # If form is submitted, delete user. Otherwise, show modal.
    if form.validate_on_submit():
        current_user.remove()
        db.session.commit()
        flash('Your account has been deleted.', 'success')
        return redirect(url_for('main.index'))
    else:
        return render_template('users/components/confirm_account_delete_modal.html',
                               username=current_user.username,
                               form=form)


@users.route('/reset-api-key', methods=['POST'])
@login_required
def reset_api_key():
    form = ResetApiKeyForm()

    if form.validate_on_submit():
        current_user.api_key = secrets.token_urlsafe(43)
        db.session.commit()
        flash('Your API key has been reset.', 'success')
        return redirect(url_for('users.account'))
    else:
        return render_template('users/components/reset_api_key_modal.html',
                               username=current_user.username,
                               form=form)


@users.route('/account/reset-password/', methods=['GET', 'POST'])
@login_required
def reset_password():
    form = ResetPasswordForm()

    if form.validate_on_submit():
        old_hashed_password = bcrypt.generate_password_hash(form.old_password.data).decode('utf-8')
        hashed_password = bcrypt.generate_password_hash(form.password.data).decode('utf-8')

        if not bcrypt.check_password_hash(current_user.password, form.old_password.data):
            flash('Your old password was incorrect.', 'warning')
            return render_template('users/reset_password.html',
                                   title='Rest Password',
                                   user=current_user,
                                   form=form)

        current_user.password = hashed_password
        db.session.commit()

        flash('Your password has been updated!', 'success')
        return redirect(url_for('users.account', username=current_user.username))

    else:
        return render_template('users/reset_password.html',
                               title='Reset Password',
                               user=current_user,
                               form=form)


@users.route('/forgot-password/', methods=['GET'])
def forgot_password():
    return render_template('users/forgot-password.html')
