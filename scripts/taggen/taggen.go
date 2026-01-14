package main

import (
	"crypto/rand"
	"fmt"
	"math/big"
	"os"
	"runtime"
	"strings"
)

var adjectives = []string{
	"admiring", "agile", "ancient", "bold", "brave",
	"bright", "calm", "clever", "cool", "cosmic",
	"daring", "eager", "elegant", "epic", "fearless",
	"fierce", "flying", "focused", "friendly", "gentle",
	"gifted", "golden", "graceful", "happy", "hopeful",
	"hungry", "jolly", "keen", "kind", "laughing",
	"lively", "lucky", "magical", "mighty", "modest",
	"musing", "nifty", "noble", "peaceful", "polite",
	"proud", "quick", "quiet", "rapid", "relaxed",
	"sharp", "shiny", "silent", "sleepy", "smart",
	"smooth", "snappy", "solid", "speedy", "stoic",
	"sunny", "sweet", "swift", "tender", "thirsty",
	"trusting", "upbeat", "vibrant", "vigilant", "warm",
	"wise", "witty", "wonderful", "zealous", "zen",
}

var nouns = []string{
	"albatross", "antelope", "badger", "bear", "beaver",
	"bird", "buffalo", "butterfly", "camel", "cat",
	"cheetah", "cobra", "condor", "crane", "deer",
	"dolphin", "dragon", "eagle", "elephant", "falcon",
	"ferret", "finch", "firefly", "fish", "flamingo",
	"fox", "frog", "gazelle", "giraffe", "goose",
	"gorilla", "hawk", "hedgehog", "heron", "horse",
	"hummingbird", "jaguar", "jellyfish", "kangaroo", "koala",
	"lemur", "leopard", "lion", "lizard", "lynx",
	"mammoth", "meerkat", "moose", "narwhal", "newt",
	"octopus", "orca", "otter", "owl", "panda",
	"panther", "parrot", "peacock", "pelican", "penguin",
	"phoenix", "pigeon", "puma", "rabbit", "raccoon",
	"raven", "salmon", "seahorse", "seal", "shark",
	"sparrow", "spider", "squid", "stork", "swan",
	"tiger", "toucan", "turtle", "unicorn", "viper",
	"walrus", "whale", "wolf", "wombat", "zebra",
}

func randomElement(slice []string) string {
	n, err := rand.Int(rand.Reader, big.NewInt(int64(len(slice))))
	if err != nil {
		return slice[0]
	}
	return slice[n.Int64()]
}

func generateName() string {
	return fmt.Sprintf("%s-%s", randomElement(adjectives), randomElement(nouns))
}

func getGoVersion() string {
	version := runtime.Version()
	version = strings.TrimPrefix(version, "go")
	parts := strings.Split(version, ".")
	if len(parts) >= 2 {
		return parts[0] + "." + parts[1]
	}
	return version
}

func main() {
	goVersion := getGoVersion()
	randomName := generateName()
	tag := fmt.Sprintf("%s-%s", goVersion, randomName)

	if len(os.Args) > 1 {
		switch os.Args[1] {
		case "--name":
			fmt.Println(randomName)
			return
		case "--version":
			fmt.Println(goVersion)
			return
		case "--help", "-h":
			fmt.Println("Usage: taggen [--name|--version|--help]")
			fmt.Println("  (no args)  Print full tag: <go-version>-<random-name>")
			fmt.Println("  --name     Print only random name")
			fmt.Println("  --version  Print only Go version")
			return
		}
	}

	fmt.Println(tag)
}
