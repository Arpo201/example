FROM python:3.10-alpine
ENV PATH="/home/arpo/app/venv/bin:$PATH"

# Update for improve security
RUN apk update && apk upgrade

# Add user
RUN addgroup -S -g 1000 arpo && adduser -S -u 1000 arpo -G arpo -D
WORKDIR /home/arpo/app
RUN chown -R arpo:arpo .
USER arpo

# Install packages
COPY requirements.txt .
RUN pip install --no-cache-dir --upgrade pip && python -m venv venv
RUN pip install --no-cache-dir -r requirements.txt

COPY --chown=arpo:arpo source/ .

EXPOSE 8000
CMD ["gunicorn", "-b", "0.0.0.0:8000", "app:app"]

