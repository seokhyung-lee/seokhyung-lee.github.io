#!/usr/bin/env python3
"""
Script to automatically update citation counts in _data/citations.yml
by fetching data from Google Scholar based on google_scholar_id from papers.bib
"""

import re
import time
import random
import requests
from bs4 import BeautifulSoup
import yaml
from pathlib import Path
from datetime import datetime


def extract_google_scholar_ids(bib_file_path):
    """Extract google_scholar_id values from papers.bib file"""
    google_scholar_ids = []

    with open(bib_file_path, "r", encoding="utf-8") as f:
        content = f.read()

    # Find all google_scholar_id entries
    pattern = r"google_scholar_id\s*=\s*\{([^}]+)\}"
    matches = re.findall(pattern, content)

    for match in matches:
        google_scholar_ids.append(match.strip())

    return google_scholar_ids


def fetch_citation_count(scholar_id, article_id, max_retries=3):
    """Fetch citation count for a given article from Google Scholar"""
    base_url = "https://scholar.google.com/citations"
    url = f"{base_url}?view_op=view_citation&hl=en&user={scholar_id}&citation_for_view={scholar_id}:{article_id}"

    # Multiple User-Agent strings for rotation
    user_agents = [
        "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
        "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.2 Safari/605.1.15",
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:121.0) Gecko/20100101 Firefox/121.0",
    ]

    for attempt in range(max_retries):
        try:
            print(f"  Attempt {attempt + 1}/{max_retries} for {article_id}")

            # Random User-Agent
            user_agent = random.choice(user_agents)

            headers = {
                "User-Agent": user_agent,
                "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8",
                "Accept-Language": "en-US,en;q=0.9",
                "Accept-Encoding": "gzip, deflate, br",
                "DNT": "1",
                "Connection": "keep-alive",
                "Upgrade-Insecure-Requests": "1",
                "Sec-Fetch-Dest": "document",
                "Sec-Fetch-Mode": "navigate",
                "Sec-Fetch-Site": "none",
                "Cache-Control": "max-age=0",
            }

            print(f"  Requesting: {url}")
            response = requests.get(url, headers=headers, timeout=30)
            response.raise_for_status()

            soup = BeautifulSoup(response.content, "html.parser")

            # Look for "Cited by X" links
            cited_by_links = soup.find_all("a", string=re.compile(r"Cited by \d+"))

            if cited_by_links:
                # Extract number from the first match
                cited_text = cited_by_links[0].get_text()
                print(f"  Found: {cited_text}")

                match = re.search(r"Cited by (\d+)", cited_text)
                if match:
                    citation_count = int(match.group(1))
                    print(f"  Citation count: {citation_count}")
                    return citation_count

            print(f"  No citation info found for {article_id}")
            return 0

        except requests.exceptions.RequestException as e:
            print(f"  HTTP Error on attempt {attempt + 1}: {e}")
            if attempt < max_retries - 1:
                wait_time = 2**attempt + random.uniform(1, 3)
                print(f"  Retrying in {wait_time:.1f} seconds...")
                time.sleep(wait_time)
            else:
                print(f"  Max retries reached for {article_id}")
                return None
        except Exception as e:
            print(f"  Unexpected error: {e}")
            return None

    return None


def update_citations_yml(citations_data, yml_file_path):
    """Update the citations.yml file with new data"""

    # Create YAML content
    yaml_content = f"""# Fallback citation counts for Google Scholar articles
# This file is used when Google Scholar API is not accessible (e.g., in GitHub Actions)
# Format: article_id: citation_count
# 
# To update citation counts:
# 1. Run: python update_citations.py
# 2. Or manually visit Google Scholar pages and update counts below
# 
# Last updated: {datetime.now().strftime('%Y-%m-%d')}

# Citation counts automatically fetched from Google Scholar
"""

    # Add citation data
    for article_id, count in citations_data.items():
        if count is not None:
            yaml_content += f"{article_id}: {count}    # {count} citations\n"
        else:
            yaml_content += (
                f"{article_id}: 0     # Could not fetch (use manual count)\n"
            )

    # Write to file
    with open(yml_file_path, "w", encoding="utf-8") as f:
        f.write(yaml_content)

    print(f"\nUpdated {yml_file_path}")


def main():
    """Main function to orchestrate the citation update process"""

    # File paths
    bib_file = "_bibliography/papers.bib"
    yml_file = "_data/citations.yml"

    # Fixed scholar ID (based on the URLs we've seen)
    scholar_id = "NURGJAwAAAAJ"

    print("🔍 Extracting Google Scholar IDs from papers.bib...")
    google_scholar_ids = extract_google_scholar_ids(bib_file)

    if not google_scholar_ids:
        print("❌ No google_scholar_id found in papers.bib")
        return

    print(f"📝 Found {len(google_scholar_ids)} article IDs: {google_scholar_ids}")

    citations_data = {}

    print("\n🌐 Fetching citation counts from Google Scholar...")

    for i, article_id in enumerate(google_scholar_ids):
        print(f"\n[{i+1}/{len(google_scholar_ids)}] Processing {article_id}...")

        # Random delay between requests (3-8 seconds)
        if i > 0:  # Skip delay for first request
            delay = random.uniform(3.0, 8.0)
            print(f"  Waiting {delay:.1f} seconds...")
            time.sleep(delay)

        citation_count = fetch_citation_count(scholar_id, article_id)
        citations_data[article_id] = citation_count

        if citation_count is not None:
            print(f"  ✅ {article_id}: {citation_count} citations")
        else:
            print(f"  ❌ {article_id}: Failed to fetch")

    print("\n📊 Citation count summary:")
    for article_id, count in citations_data.items():
        status = f"{count} citations" if count is not None else "Failed to fetch"
        print(f"  {article_id}: {status}")

    print(f"\n💾 Updating {yml_file}...")
    update_citations_yml(citations_data, yml_file)

    print("✅ Citation update complete!")

    # Print statistics
    successful = sum(1 for count in citations_data.values() if count is not None)
    total_citations = sum(
        count for count in citations_data.values() if count is not None
    )

    print(f"\n📈 Statistics:")
    print(f"  Successfully fetched: {successful}/{len(google_scholar_ids)} articles")
    print(f"  Total citations: {total_citations}")

    if successful < len(google_scholar_ids):
        print(
            f"\n⚠️  Warning: {len(google_scholar_ids) - successful} articles failed to fetch."
        )
        print("   You may need to manually update their citation counts.")


if __name__ == "__main__":
    main()
