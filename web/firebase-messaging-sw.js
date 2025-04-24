importScripts('https://www.gstatic.com/firebasejs/9.6.10/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/9.6.10/firebase-messaging-compat.js');

const firebaseConfig = {
  apiKey: 'AIzaSyCiouzNgvu_hh88lKOhgy33S_NvA2yfNc4',
  authDomain: "mapspachuca-ae9e8.firebaseapp.com",
  projectId: 'mapspachuca-ae9e8',
  storageBucket: 'mapspachuca-ae9e8.firebasestorage.app',
  messagingSenderId: "892878066374",
  appId: "1:892878066374:web:ebc8be0dbb91976be67dc7"
};

firebase.initializeApp(firebaseConfig);
const messaging = firebase.messaging();
