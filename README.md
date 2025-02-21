# My Personal Data Warehouse

This project is designed to store personal data. I've been interested in the quantiifed self movement for some time and I also work in data every day. I would like to have a system to universally store data about myself. I will document and store the code to make that possible here.

--- 

# Install

**1. Install `pipenv`**

Install `pipenv` using `pip`:

```bash
pip install pipenv
```

**2. Install dependencies**

Install the dependencies using `pipenv`:

```bash
pipenv install
```

**3. Set up environment variables**

- Copy `.env.template` to `.env`:

```bash
cp .env.template .env
```

- Edit the `.env` file with your credentials and postgres information

**4. Create database and tables**

- Create the database:

```bash
pipenv run python db_setup.py
```
