import { Auth } from 'aws-amplify';

export async function signUp(username, password, email) {
  try {
    const { user } = await Auth.signUp({
      username,
      password,
      attributes: {
        email,  // Asegúrate de que el email se pase como un atributo
      }
    });
    console.log('Usuario registrado exitosamente:', user);
    return user;
  } catch (error) {
    console.error('Error al registrar usuario:', error);
    throw error;
  }
}

export async function confirmSignUp(username, code) {
  try {
    await Auth.confirmSignUp(username, code);
    console.log('Registro confirmado exitosamente');
  } catch (error) {
    console.error('Error al confirmar el registro:', error);
    throw error;
  }
}

export async function signIn(username, password) {
  try {
    const user = await Auth.signIn(username, password);
    console.log('Inicio de sesión exitoso');
    return user;
  } catch (error) {
    console.error('Error al iniciar sesión:', error);
    throw error;
  }
}

export async function signOut() {
  try {
    await Auth.signOut();
    console.log('Cierre de sesión exitoso');
  } catch (error) {
    console.error('Error al cerrar sesión:', error);
    throw error;
  }
}

export async function getCurrentUser() {
  try {
    const user = await Auth.currentAuthenticatedUser();
    console.log('Usuario actual obtenido:', user);
    return user;
  } catch (error) {
    console.error('Error al obtener el usuario actual:', error);
    return null;
  }
}

export async function forgotPassword(username) {
  try {
    await Auth.forgotPassword(username);
    console.log('Código de recuperación enviado');
  } catch (error) {
    console.error('Error al solicitar recuperación de contraseña:', error);
    throw error;
  }
}

export async function forgotPasswordSubmit(username, code, newPassword) {
  try {
    await Auth.forgotPasswordSubmit(username, code, newPassword);
    console.log('Contraseña restablecida exitosamente');
  } catch (error) {
    console.error('Error al restablecer la contraseña:', error);
    throw error;
  }
}

export async function changePassword(user, oldPassword, newPassword) {
  try {
    await Auth.changePassword(user, oldPassword, newPassword);
    console.log('Contraseña cambiada exitosamente');
  } catch (error) {
    console.error('Error al cambiar la contraseña:', error);
    throw error;
  }
}