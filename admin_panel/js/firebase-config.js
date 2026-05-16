// Firebase Configuration for Admin Panel
// Using project: safenet-ai-61658
const firebaseConfig = {
  apiKey: "AIzaSyCewKUuVhaZkyGmfMD0Qje0E5prgqU3BGY",
  authDomain: "safenet-ai-61658.firebaseapp.com",
  projectId: "safenet-ai-61658",
  storageBucket: "safenet-ai-61658.firebasestorage.app",
  messagingSenderId: "242326046756",
  appId: "1:242326046756:android:c1621061415fdb64d9b0b1"
};

firebase.initializeApp(firebaseConfig);
const db = firebase.firestore();
const auth = firebase.auth();
