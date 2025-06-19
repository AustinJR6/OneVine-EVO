import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import axios from 'axios';

admin.initializeApp();

const GEMINI_API_KEY = functions.config().gemini?.key || process.env.GEMINI_API_KEY;
const GEMINI_URL = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent';

async function callGemini(prompt: string): Promise<string> {
  const res = await axios.post(`${GEMINI_URL}?key=${GEMINI_API_KEY}`, {
    contents: [{ parts: [{ text: prompt }] }],
  });
  return res.data.candidates?.[0]?.content?.parts?.[0]?.text || '';
}

export const askGeminiV2 = functions.https.onCall(async (data) => {
  const history: Array<{ role: string; text: string }> = data.history || [];
  const religion: string = data.religion || 'Christian';
  const conversation = history.map((m) => `${m.role}: ${m.text}`).join('\n');
  const prompt = `Act as a spiritual guide of ${religion}. Continue the conversation:\n${conversation}`;
  const text = await callGemini(prompt);
  return { text };
});

export const getDailyChallenge = functions.https.onCall(async (data) => {
  const religion: string = data.religion || 'Christian';
  const prompt = `Provide a short daily challenge for a follower of ${religion}.`;
  const text = await callGemini(prompt);
  return { text };
});

export const getMilestoneBlessing = functions.https.onCall(async (data) => {
  const religion: string = data.religion || 'Christian';
  const streak: number = data.streak || 0;
  const prompt = `Offer a brief blessing from the perspective of ${religion} for achieving a ${streak}-day streak.`;
  const text = await callGemini(prompt);
  return { text };
});
