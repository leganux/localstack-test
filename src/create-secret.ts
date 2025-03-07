import { CreateSecretCommand, SecretsManagerClient } from '@aws-sdk/client-secrets-manager';

const client = new SecretsManagerClient({ region: "us-east-1", endpoint: 'http://localhost:4566' });

const createSecretCommand = new CreateSecretCommand({
    Name: 'dev-rumor',
    SecretString: JSON.stringify({
            PORT: 8000,
            POSTGRES_USERNAME: "rumor",
            POSTGRES_PASSWORD: "rumor",
            POSTGRES_DATABASE: "rumor",
            POSTGRES_PORT: 5432,
            POSTGRES_HOST: "localhost",
            USERS_SERVICE_BASE_URL: "http://users:8000/users/v1",
            EVENTS_SERVICE_BASE_URL: "http://events:8001/events/v1",
            NOTIFICATIONS_SERVICE_BASE_URL:
                "http://notifications:8002/notifications/v1",
    }),
});

client.send(createSecretCommand)
  .then(data => {
    console.log(`Secret created ${data.Name}`);
  })
  .catch(error => {
    console.error('Error creating secret:', error);
  });
