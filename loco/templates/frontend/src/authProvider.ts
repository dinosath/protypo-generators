import { AuthProvider, HttpError } from "react-admin";
import data from "./users.json";

const url="http://localhost:5150";

const authProvider = {
  login: ({ username, password }) =>  {
    const request = new Request(`${url}/api/auth/login`, {
      method: 'POST',
      body: JSON.stringify({ username, password }),
      headers: new Headers({ 'Content-Type': 'application/json' }),
    });
    return fetch(request)
        .then(response => {
          if (response.status < 200 || response.status >= 300) {
            throw new Error(response.statusText);
          }
          return response.json();
        })
        .then(auth => {
          localStorage.setItem('auth', JSON.stringify(auth));
        })
        .catch(() => {
          throw new Error('Network error')
        });
  },
  logout: () => {
    localStorage.removeItem('username');
    return Promise.resolve();
  },
  checkAuth: () => localStorage.getItem('auth')
      ? Promise.resolve()
      : Promise.reject(),
  getPermissions: () => {
    // Required for the authentication to work
    return Promise.resolve();
  },
  // ...
};

export default authProvider;
