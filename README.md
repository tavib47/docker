## Build and commit the image

```

docker build -t drupal-php .
docker tag commit_hash tavib47/drupal-php:tagname
docker push tavib47/drupal-php:tagname

```

## Test the image

```
docker run -ti drupal-php sh
```