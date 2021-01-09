import JSONAPIClient from 'json-api-client'

const PATH_TO_API_ROOT = `${window.location.protocol}//${
  window.location.host
}/` // 'http://localhost:3000/'

console.log(PATH_TO_API_ROOT)

const DEFAULT_HEADERS = {
  'Content-Type': 'application/json',
  Accept: 'application/vnd.api+json; version=1'
}

const client = new JSONAPIClient(PATH_TO_API_ROOT, DEFAULT_HEADERS)

console.log('JSONAPIClient instance:', client)

export default client
