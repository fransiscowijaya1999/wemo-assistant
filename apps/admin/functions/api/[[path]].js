export function onRequest(context) {
  const { request, env, params } = context;
  const url = new URL(request.url);
  const path = Array.isArray(params.path) ? params.path.join('/') : (params.path ?? '');
  const target = env.BACKEND_URL.replace(/\/+$/, '') + '/' + path + url.search;
  return fetch(new Request(target, request)); // preserves method, headers (Authorization), body
}