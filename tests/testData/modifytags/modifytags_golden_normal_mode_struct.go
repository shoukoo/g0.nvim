package modifytags

import (
	"errors"
	"fmt"
	"time"
)

var ErrNotOnAnyBranch = errors.New("git: not on any branch")

type NotInstalled struct {
	message string
	err     error
}

type PullRequest struct {
	ID                  string     `json:"id"`
	Number              int        `json:"number"`
	Title               string     `json:"title"`
	State               string     `json:"state"`
	Closed              bool       `json:"closed"`
	URL                 string     `json:"url"`
	BaseRefName         string     `json:"baseRefName"`
	HeadRefName         string     `json:"headRefName"`
	HeadRefOid          string     `json:"headRefOid"`
	Body                string     `json:"body"`
	Mergeable           string     `json:"mergeable"`
	Additions           int        `json:"additions"`
	Deletions           int        `json:"deletions"`
	ChangedFiles        int        `json:"changedFiles"`
	MergeStateStatus    string     `json:"mergeStateStatus"`
	IsInMergeQueue      bool       `json:"isInMergeQueue"`
	IsMergeQueueEnabled bool       `json:"isMergeQueueEnabled"`
	CreatedAt           time.Time  `json:"createdAt"`
	UpdatedAt           time.Time  `json:"updatedAt"`
	ClosedAt            *time.Time `json:"closedAt"`
	MergedAt            *time.Time `json:"mergedAt"`

	Files struct {
		Nodes     []string   `json:"nodes"`
		CreatedAt time.Time  `json:"createdAt"`
		UpdatedAt time.Time  `json:"updatedAt"`
		ClosedAt  *time.Time `json:"closedAt"`
		MergedAt  *time.Time `json:"mergedAt"`
	} `json:"files"`
}

func (e *NotInstalled) Error() string {
	return e.message
}

func (e *NotInstalled) Unwrap() error {
	return e.err
}

type GitError struct {
	ExitCode int
	Stderr   string
	err      error
}

func (ge *GitError) Error() string {
	if ge.Stderr == "" {
		return fmt.Sprintf("failed to run git: %v", ge.err)
	}
	return fmt.Sprintf("failed to run git: %s", ge.Stderr)
}

func (ge *GitError) Unwrap() error {
	return ge.err
}
