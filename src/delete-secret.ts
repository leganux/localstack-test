import { DeleteSecretCommand, SecretsManagerClient } from '@aws-sdk/client-secrets-manager';

const client = new SecretsManagerClient({ region: "us-east-1", endpoint: 'http://localhost:4566' });

const deleteSecretCommand = new DeleteSecretCommand({
  SecretId: 'dev-rumor',
  ForceDeleteWithoutRecovery: true
});

client.send(deleteSecretCommand).then(data => {
  console.log('Secret deleted', data.Name);
});