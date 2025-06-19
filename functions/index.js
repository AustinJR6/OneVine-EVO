import functions from 'firebase-functions';
import admin from 'firebase-admin';
import axios from 'axios';
import express from 'express';

admin.initializeApp();
const app = express();
app.use(express.json());

const GEMINI_API_KEY = process.env.GEMINI_API_KEY;
const GEMINI_URL = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent';

async function callGemini(prompt) {
  const res = await axios.post(`${GEMINI_URL}?key=${GEMINI_API_KEY}`,
    { contents: [{ parts: [{ text: prompt }] }] });
  return res.data.candidates?.[0]?.content?.parts?.[0]?.text || '';
}

app.post('/dailyChallenge', async (req, res) => {
  try {
    const { religion, context } = req.body;
    const prompt = `Provide a daily challenge for a follower of ${religion}. ${context ?? ''}`;
    const text = await callGemini(prompt);
    res.json({ text });
  } catch (e) {
    console.error(e);
    res.status(500).send('error');
  }
});

app.post('/confessional', async (req, res) => {
  try {
    const { message, religion } = req.body;
    const prompt = `Act as a spiritual guide of ${religion} and respond to: ${message}`;
    const text = await callGemini(prompt);
    res.json({ text });
  } catch (e) {
    console.error(e);
    res.status(500).send('error');
  }
});

app.post('/spiritualQuestion', async (req, res) => {
  try {
    const { question, religion } = req.body;
    const prompt = `Answer with empathy and accuracy from the perspective of ${religion}: ${question}`;
    const text = await callGemini(prompt);
    res.json({ text });
  } catch (e) {
    console.error(e);
    res.status(500).send('error');
  }
});

app.post('/trivia', async (req, res) => {
  try {
    const { religion } = req.body;
    const prompt = `Provide a faith-based trivia question for ${religion} without revealing the answer.`;
    const text = await callGemini(prompt);
    res.json({ text });
  } catch (e) {
    console.error(e);
    res.status(500).send('error');
  }
});

export const api = functions.https.onRequest(app);
