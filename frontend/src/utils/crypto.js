const encoder = new TextEncoder();
const decoder = new TextDecoder();

async function deriveKey(secret) {
  const keyMaterial = await crypto.subtle.importKey(
    'raw',
    encoder.encode(secret),
    'PBKDF2',
    false,
    ['deriveKey'],
  );

  return crypto.subtle.deriveKey(
    {
      name: 'PBKDF2',
      salt: encoder.encode('scientific-fund-salt'),
      iterations: 100000,
      hash: 'SHA-256',
    },
    keyMaterial,
    { name: 'AES-GCM', length: 256 },
    false,
    ['encrypt', 'decrypt'],
  );
}

export async function encryptText(value, secret) {
  if (!value || !secret) {
    throw new Error('El valor a cifrar y el secreto son obligatorios.');
  }

  const key = await deriveKey(secret);
  const iv = crypto.getRandomValues(new Uint8Array(12));
  const encoded = encoder.encode(value);
  const cipher = await crypto.subtle.encrypt({ name: 'AES-GCM', iv }, key, encoded);

  return {
    iv: Array.from(iv),
    payload: Array.from(new Uint8Array(cipher)),
  };
}

export async function decryptText(encryptedValue, secret) {
  if (!encryptedValue || !secret) {
    throw new Error('El valor cifrado y el secreto son obligatorios.');
  }

  const key = await deriveKey(secret);
  const iv = new Uint8Array(encryptedValue.iv);
  const payload = new Uint8Array(encryptedValue.payload);
  const decrypted = await crypto.subtle.decrypt({ name: 'AES-GCM', iv }, key, payload.buffer);

  return decoder.decode(decrypted);
}

export function serializeEncrypted(value) {
  return JSON.stringify(value);
}

export function parseEncrypted(value) {
  return JSON.parse(value);
}
